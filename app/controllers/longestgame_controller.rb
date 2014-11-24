require 'open-uri'
require 'json'

class LongestgameController < ApplicationController


  def game
    @grid = generate_grid(10)
    @start_time = Time.now
    session[:name] = "thierry"
  end

  def score
    @shot = params[:shot]
    @grid = params[:grid].split(" ")
    @start_time = Time.parse(params[:time])
    @end_time = Time.now
    @result = run_game(@shot, @grid, @start_time, @end_time)
    (session[:results] ||= []) << @result[:score]
  end


private

  # def current_user
  #   @_current_user ||= session[:current_user_id] &&
  #     User.find_by(id: session[:current_user_id])
  # end

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    # on va prendre des caracteres au hazard
    # et les mettre dans un array
    # ["Q", "F", "M", "R", "K", "L", "I", "T", "P"]
    array = []
    grid_size.times do
      array  << (65 + rand(25)).chr
    end

    return array
  end



  def attempt_in_grid?(attempt, grid)
    # verifier si le resultat qu on marche  bien avec les lettres
    attempt_check = attempt.upcase.chars

    # on prend chaque caractere de attemps, on regarde si il est dans grid et on le vire
    # sub permet de faire le test sur une string sinon
    attempt_check.each do |x|
      if grid.include?(x)
        grid.delete_at(grid.index(x) || grid.length)
      else
        return false
      end
    end
    return true
  end


  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    hash = { time: end_time - start_time }

    if attempt_in_grid?(attempt, grid)

      # on commence par choper et parser le JSON
      traduc_hash = JSON.parse(open("http://api.wordreference.com/0.8/80143/json/enfr/#{attempt}").read)

      # est-ce qu on recoit un message d erreur
      if traduc_hash["Error"] == "NoTranslation"
        return hash.merge(message: "not an english word", translation: nil, score: 0)

      else      # trouver la bonne donnee
        traduc_word = traduc_hash["term0"]["PrincipalTranslations"]["0"]["FirstTranslation"]["term"]
        score = (attempt.length.fdiv(9) * 1.fdiv(hash[:time]) *1_000).round
        return hash.merge(translation: traduc_word, score: score, message: "well done")
      end

    else
      return hash.merge(message: "not in the grid", score: 0)
    end
  end
end
