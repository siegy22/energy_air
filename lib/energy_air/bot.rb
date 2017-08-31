# coding: utf-8
module EnergyAir
  class Bot
    include Capybara::DSL

    def initialize(tel_number)
      @tel_number = tel_number
      Capybara.run_server = false
      Capybara.register_driver :chrome_poltergeist do |app|
        chrome_poltergeist = Capybara::Poltergeist::Driver.new(app)
        chrome_poltergeist.headers = {
          'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/55.0.2883.95 Safari/537.36'
        }
        chrome_poltergeist.timeout = 100
        chrome_poltergeist
      end
      Capybara.current_driver = :chrome_poltergeist

      loop { run }
    end

    def run
      visit 'https://game.energy.ch'
      override_validation_function
      enter_tel_number
      answer_question until finished?
      choose_random_bubble
      if won?
        print "√"
      else
        print "."
      end
    rescue StandardError => e
      print "× (#{e})"
    ensure
      reset_browser
    end

    private
    def override_validation_function
      page.execute_script("window.checkForm = function(){ return true; }")
    end

    def enter_tel_number
      find("input#mobile").set(@tel_number)
      click_on("LOS GEHTS")
    end

    def answer_question
      current_question = find(".question h1").text
      answer = QUESTIONS[current_question]
      choose("option#{answer}")
      click_on("WEITER")
    end

    def finished?
      all("h2").map(&:text).include?("Glückwunsch!")
    end

    def choose_random_bubble
      click_on("WEITER GEHTS!")
      all("#wingame a").sample.click
    end

    def lost?
      find("h1").text == "Das war das falsche Logo, knapp daneben! Versuche es erneut!"
    end

    def won?
      !lost?
    end

    def reset_browser
      page.driver.clear_cookies
      Capybara.reset_sessions!
    end

    QUESTIONS = {
      "Wie gross ist die Spielfläche des Stade de Suisse?" => 2, # ["100m x 70m", "105m x 68m", "90m x 40m"]
      "Wie hiess das Stade de Suisse früher?" => 1, # ["Wankdorf", "Stade de YB", "Wenkdorf"]
      "Was bedeutet Air auf Deutsch?" => 2, # ["Konzert", "Luft", "Liebe"]
      "Von welchem ehemaligen Energy Air Act ist der Song «Bilder im Kopf»?" => 1, # ["Sido", "MoTrip", "Culcha Candela"]
      "Mit welchem Künstler stand Schlangenfrau Nina Burri auf der Bühne?" => 1, # ???["RedOne", "DJ Antoine", "OneRepublic"]
      "Wann wurde das Stade de Suisse offiziell fertig gestellt?" => 1, # ["2005", "2000", "2001"]
      "In welcher Schweizer Stadt hat Energy KEIN Radiostudio?" => 3, # ["Bern", "Basel", "St. Gallen"]
      "Welcher DJ stand noch nie auf der Energy Air Bühne?" => 2, # ["Kygo", "Felix Jaehn", "DJ Antoine"]
      "Wie viele Tage dauert das Energy Air?" => 3, # ["3", "2", "1"]
      "Wann findet das diesjährige Energy Air statt?" => 2, # ["3. September 2017", "2. September 2017", "31. August 2017"]
      "Wo findet das Energy Air statt?" => 3, # ["Zürich, Letzigrund", "Basel, St. Jakobshalle", "Bern, Stade de Suisse"]
      "Welche Plätze gibt es am Energy Air?" => 3, # ["Nur Stehplätze", "Nur Sitzplätze", "XTRA Circle-Tickets, Steh- und Sitzplätze"]
      "Wann fand das erste Energy Air statt?" => 3, # ["Samstag, 6. September 2014", "Freitag, 5. September 2014", "Sonntag, 7. September 2014"]
      "Wie hiess der Energy Air Song im Jahr 2014?" => 3, # ["Energy", "Air", "Dynamite"]
      "Wie viele Male standen Dabu Fantastic bereits auf der Energy Air Bühne?" => 1, # ["2 Mal", "Kein Mal", "1 Mal"]
      "Zum wievielten Mal findet das Energy Air statt?" => 2, # ["Zum 3. Mal", "Zum 4. Mal", "Zum 5. Mal"],
      "Das Energy Air ist ...?" => 1,
      "Ab wann darf man, ohne eine erwachsene Begleitperson, am Energy Air teilnehmen?" => 1,
      "Was ist die obere Altersbeschränkung des Energy Air?" => 2,
      "Wie viel kostet die Energy Air App?" => 2,
      "Welcher dieser Acts Stand schon auf der Stade de Suisse Bühne?" => 1,
      "Welcher Act stand NOCH NIE auf der Energy Air Bühne?" => 3,
      "Wie viele Sitzplätze hat das Stade de Suisse bei Sportveranstaltungen?" => 1,
      "Wer hatte den letzten Auftritt am Energy Air 2016?" => 3,
      "Wie viele Zuschauer passen ins Stade de Suisse?" => 1,
      "In welchem Monat findet das Energy Air jeweils statt?" => 2,
      "Welcher Fussballverein ist im Stade de Suisse Zuhause?" => 1,
      "Was ist das Energy Air als einziger Energy Event?" => 1,
      "Welcher Energy Air Act aus den letzten Jahren stand nur mit seinem Gitarristen auf der Bühne?" => 1,
      "Welches Stadion ist das grösste der Schweiz?" => 1,
      "Welcher Act stand schon einmal auf der Energy Air Bühne?" => 1,
      "Wie lautet der offizielle Energy Air Hashtag?" => 3,
      "Welcher Künstler stand NOCH NIE auf der Energy Air Bühne?" => 1,
      "Wie hiess die Energy Air Hymne 2015?" => 1,
      "Von welchem vergangenen Energy Air Act ist der Song «Angelina»?" => 1,
      "Welcher Act performte in einem Karton-Hippie-Bus?" => 3,
      "Wie heissen zwei andere grosse Events von Energy?" => 1,
      "In welchem Jahr stand OneRepublic auf der Bühne des Energy Air?" => 1,
      "Welche deutsche Sängerin stand letztes Jahr auf der Energy Air Bühne?" => 1,
      "Wie viel kostet ein Energy Air Ticket?" => 1,
      "Von wem wird das Energy Air durchgeführt?" => 1,
      "Wie oft pro Jahr findet das Energy Air statt?" => 3,
      "Wie viele Tickets werden für das Energy Air verlost?" => 1,
      "Wo kann man Energy Air Tickets kaufen?" => 3,
      "Welche Farben dominieren das Energy Air Logo?" => 1,
      "Welcher Pop-Sänger stand in diesem Jahr schon auf der Bühne des Stade de Suisse?" => 1,
      "Wann ist die offizielle Türöffnung beim Energy Air?" => 1,
      "Wann fand das Energy Air letztes Jahr statt?" => 1
    }
  end
end
