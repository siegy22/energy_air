require 'capybara'
require 'capybara/dsl'
require 'webdrivers/chromedriver'
require 'selenium/webdriver'
require 'energy_air/questions'

Capybara.run_server = false

# coding: utf-8
module EnergyAir
  class Bot
    class UnknownQuestionError < StandardError; end

    include Capybara::DSL

    def initialize(tel_number, visual: false)
      Capybara.current_driver = visual ? :selenium_chrome : :selenium_chrome_headless
      @tel_number = tel_number

      register
      loop { run }
    end

    def register
      visit 'https://game.energy.ch'

      fill_in 'inlineFormInput', with: @tel_number
      click_on 'Verifizieren'
      check_for_error

      print 'Activation code (received via SMS): '
      activation_code = $stdin.gets.strip
      activation_code.chars.each.with_index do |num, index|
        fill_in (index + 1).to_s, with: num
      end
      sleep 5
      click_on 'Verifizieren'
    end

    def run
      visit 'https://game.energy.ch'
      answer_question until finished?

      return register if reconfirmation_needed?
      return if lost?

      choose_random_bubble

      if won?
        print "√\a"
        sleep
      else
        print '.'
      end
    rescue StandardError => e
      print "× (#{e})"
    end

    private

    def answer_question
      current_question = find('.question-text').text
      answer = EnergyAir::QUESTIONS.fetch(current_question) do
        raise UnknownQuestionError, "Cannot find an answer to the question: #{current_question}"
      end

      2.times { find('label', text: answer).click }
      click_on 'Weiter'
    end

    def finished?
      all('.question-text').empty?
    end

    def choose_random_bubble
      all('.circle').sample.click
    end

    def lost?
      all('h1').map(&:text).include?('Leider verloren')
    end

    def lost_bubble?
      all('img[src="https://cdn.energy.ch/game-web/images/eair/bubble-lose.png"]').any?
    end

    def won?
      !lost_bubble?
    end

    def check_for_error
      if all('.error-message').any?
        warn "An error message appeared: #{find('.error-message').text}\nExiting.."
        exit
      end
    end

    def reconfirmation_needed?
      all('.title-verification').any?
    end
  end
end
