# coding: utf-8
require "tempfile"
require "securerandom"
require "capybara"
require "capybara/dsl"
require 'webdrivers/chromedriver'
require "selenium/webdriver"

Capybara.run_server = false
Capybara.current_driver = :selenium_chrome

# coding: utf-8
module EnergyAir
  class Bot
    include Capybara::DSL

    def initialize(tel_number)
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
      return if all('h1', text: 'Leider verloren').any?
      choose_random_bubble
      if won?
        print "√"
      else
        print "."
      end
    rescue StandardError => e
      print "× (#{e})"
    end

    private

    def answer_question
      current_question = find(".question-text").text
      answer = QUESTIONS[current_question]
      find('label', text: answer).click
      click_on("Weiter")
    rescue Capybara::ElementNotFound
      visit 'https://game.energy.ch'
    end

    def finished?
      all('.question-text').empty?
    end

    def choose_random_bubble
      all(".circle").sample.click
    end

    def lost?
      all('img[src="https://cdn.energy.ch/game-web/images/eair/bubble-lose.png"]').any?
    end

    def won?
      !lost?
    end

    def check_for_error
      if all('.error-message').any?
        warn "An error message appeared: #{find('.error-message').text}\nExiting.."
        exit
      end
    end

    QUESTIONS = {
      "Was passiert, wenn es am Eventtag regnet?" => "Energy Air findet trotzdem statt",
      "Energy Air Tickets kann man…" => "gewinnen",
      "Energy Air ist der einzige Energy Event, …" => "...der unter freiem Himmel stattfindet.",
      "Wie viele Mitarbeiter sind am Energy Air im Einsatz?" => "1300",
      "Wie reiste Kygo im Jahr 2015 ans Energy Air?" => "Im Privatjet",
      "Wie breit ist die Energy Air Bühne?" => "70 Meter",
      "Wie viele Energy Air Tickets werden verlost?" => "40’000",
      "Auf welcher Social-Media-Plattform kann man keine Energy Air Tickets gewinnen?" => "Twitter",
      "Wann beginnt das Energy Air 2019?" => "Um 17 Uhr",
      "Die wievielte Energy Air Ausgabe findet dieses Jahr statt?" => "Die fünfte",
      "Was verlangte Nena am Energy Air 2016?" => "Eine komplett weisse Garderobe",
      "Welche DJ-Acts standen 2018 auf der Bühne des Energy Air?" => "Averdeck",
      "Wie schwer ist die Energy Air Bühne?" => "1000 Tonnen",
      "Wie viele Acts waren beim letzten Energy Air dabei?" => "15",
      "Wie viele Konfetti-Kanonen gibt es am Energy Air?" => "40",
      "Welcher dieser Acts hatte einen Auftritt am Energy Air 2018?" => "DJ Antoine",
      "Wann fand das Energy Air zum ersten Mal statt?" => "2014",
      "Wann findet das Energy Air 2019 statt?" => "7. September 2019",
      "Wo erfährst du immer die neusten Infos rund um das Energy Air?" => "im Radio, auf der Website und über Social Media",
      "Welche amerikanische Band trat am Energy Air 2016 auf?" => "One Republic",
      "Wo findet das Energy Air statt?" => "Stade de Suisse, Bern",
      "Auf welchem Weg kann man KEINE Energy Air Tickets gewinnen?" => "E-Mail",
      "Wer war der letzte Act am Energy Air 2018?" => "Lo & Leduc",
      "Mit welchem dieser Tickets geniesst du die beste Sicht zur Energy Air Bühne?" => "Sitzplatz",
      "Wie viele Spotlights gibt es am Energy Air?" => "250",
      "Wen nahm Knackeboul am Energy Air 2014 mit backstage?" => "Sein Mami",
      "Welche Fussballmannschaft ist im Stade de Suisse zuhause?" => "BSC Young Boys",
      "Wer eröffnete das erste Energy Air?" => "Bastian Baker",
    }.map { |k, v| [k.upcase, v] }.to_h.freeze
  end
end
