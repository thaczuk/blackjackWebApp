# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'pry'

set :sessions, true

BLACKJACK_AMOUNT = 21
DEALER_MIN_HIT = 17
INITIAL_POT = 500

helpers do
  def total(cards)
    face_values = cards.map { |card| card[1] }
    total = 0
    face_values.each do |value|
      if value == 'J' ||  value == 'Q' || value == 'K' then total += 10
      elsif  value == 'A'
        total += 11
        total -= 10 if total > BLACKJACK_AMOUNT
      else total += value.to_i
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

  def card_image(card)
  suit = find_suit(card[0])
  value = find_face_value(card[1])

  "<img src='/images/cards/#{suit}_#{value}.jpg' class='fixed_width' />"
  end

  def name_error!(msg)
    @alert_message = msg
    @alert_type = 'alert_error'
    halt erb :new_player
  end

  def blackjack!
    @game_over = true
    @alert_message = 'BLACKJACK! You win.'
    @alert_type = 'alert-success'
    session[:player_pot] = session[:player_pot] + session[:player_bet]
  end

  def win!(msg="")
    @alert_message = "You win. #{msg}"
    @alert_type = 'alert-success'
    @game_over = true
    session[:player_pot] = session[:player_pot] + session[:player_bet]
  end

  def lose!(msg="")
    @alert_message = "You lose. #{msg}"
    @alert_type = 'alert-error'
    @game_over = true
    session[:player_pot] = session[:player_pot] - session[:player_bet]
  end

  def tie!
    @alert_message = 'Tie. Both player and dealer had the same score'
    @alert_type = 'alert-error'
    @game_over = true
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

  if total(session[:player_cards]) == BLACKJACK_AMOUNT
    blackjack!
  end

  erb :game
end

post '/hit' do
  session[:player_cards] << session[:deck].pop
  if total(session[:player_cards]) == BLACKJACK_AMOUNT
    blackjack!
  elsif total(session[:player_cards]) > BLACKJACK_AMOUNT
    lose!("You bust with #{total(session[:player_cards])}.")
  end
  erb :game, layout: false
end

post '/stay' do
  while total(session[:dealer_cards]) < DEALER_MIN_HIT
    session[:dealer_cards] << session[:deck].pop
  end

  if total(session[:dealer_cards]) == BLACKJACK_AMOUNT
    lose!('Dealer has blackjack!')
  elsif total(session[:dealer_cards]) > BLACKJACK_AMOUNT
    win!('Dealer busts')
  elsif total(session[:player_cards]) > total(session[:dealer_cards])
    win!('Your score is higher than the dealer.')
  elsif total(session[:player_cards]) < total(session[:dealer_cards])
    lose!('Your score is lower than the dealer.')
  else
    tie!
  end
  erb :game
end

get '/new_player' do
   erb :new_player
end

post '/new_player' do
  if params[:player_name].empty?
    name_error!('Oh no! You forgot to enter your name!')
  elsif !(/^[A-Z]+$/i.match(params[:player_name]))
    name_error!('Please enter a valid name')
  end
  session[:player_pot] = INITIAL_POT
  session[:player_name] = params[:player_name]
  redirect '/bet'
end

get '/rules' do
  erb :rules
end

get '/about' do
  erb :about
end

get '/new_game' do
  @game_over = false
  redirect '/'
end

get '/bet' do
  session[:player_bet] = nil
  erb :bet
end

post '/bet' do
  if params[:amount_bet].nil? || params[:amount_bet].to_i == 0
    halt erb :bet
  elsif params[:amount_bet].to_i > session[:player_pot]
    @alert_message = "You don't have that much money!"
    @alert_type = 'alert_error'
    halt erb :bet
  end

  session[:player_bet] = params[:amount_bet].to_i
  redirect '/game'
end