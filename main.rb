# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

helpers do
  def total(cards)
    face_values = cards.map{ |card| card[1] }

    total = 0
    face_values.each do |value|
      if value == 'J' ||  value == 'Q' || value == 'K'
        total += 10
      elsif  value == 'A'
        total += 11
        total -= 10 if total > 21
      else
        total += value.to_i
      end
    end
    total
  end

  def find_suit(suit)
    value = case suit
      when 'H' then 'hearts'
      when 'D' then 'diamonds'
      when 'S' then 'spades'
      when 'C' then 'clubs'
    end
    value
  end

  def find_face_value(face_value)
    value = case face_value
      when '2' then '2'
      when '3' then '3'
      when '4' then '4'
      when '5' then '5'
      when '6' then '6'
      when '7' then '7'
      when '8' then '8'
      when '9' then '9'
      when '10' then '10'
      when 'J' then 'jack'
      when 'Q' then 'queen'
      when 'K' then 'king'
      when 'A' then 'ace'
    end
    value
  end
end

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/game' do
  # create a deck and put it in session
  suits = %w[ H D C S ]
  values = %w[ 2 3 4 5 6 7 8 9 10 J Q K A ]
  session[:deck] = suits.product(values).shuffle!

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  if total( session[:player_cards] ) == 21
    @alert_message = "BLACKJACK! You win."
    @alert_type = "alert-success"
    @game_over = true
  end

  erb :game
end

post '/hit' do
  session[:player_cards] << session[:deck].pop
  if total( session[:player_cards] ) == 21
    @alert_message = "BLACKJACK! You win."
    @alert_type = "alert-success"
    @game_over = true
  elsif total( session[:player_cards] ) > 21
    @alert_message = "Bust! You lose."
    @alert_type = "alert-error"
    @game_over = true
  end
  erb :game
end

post '/stay' do
  while total( session[:dealer_cards] ) < 17
    session[:dealer_cards] << session[:deck].pop
  end

  if total( session[:dealer_cards] ) == 21
    @alert_message = "Dealer has blackjack! You lose."
    @alert_type = "alert-error"
    @game_over = true
  elsif total( session[:dealer_cards] ) > 21
    @alert_message = "Dealer busts! You win!"
    @alert_type = "alert-error"
    @game_over = true
  elsif total( session[:player_cards] ) > total( session[:dealer_cards] )
    @alert_message = "Your score is higher than the dealer. You win!"
    @alert_type = "alert-success"
    @game_over = true
  else
    @alert_message = "Your score isn't higher than the dealer. You lose."
    @alert_type = "alert-error"
    @game_over = true
  end
  erb :game
end

get '/new_player' do
   erb :new_player
end

post '/new_player' do
  session[:player_name] = params[:player_name]
  if session[:player_name].length == 0
    @alert_message = "Oh no! You forgot to enter your name!"
    @alert_type = "alert_error"
    erb :new_player
  else
    redirect '/game'
  end
end

get '/rules' do
  erb :rules
end

get '/about' do
  erb :about
end

post '/new_game' do
  @game_over = false
  redirect '/'
end