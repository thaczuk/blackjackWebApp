# encoding: utf-8
require 'rubygems'
require 'sinatra'

set :sessions, true

get '/' do
  if session[:player_name]
    redirect '/game'
  else
    redirect '/new_player'
  end
end

get '/game' do
  # create a deck and put it in session
  suits = %w[ H, D, C, S ]
  values = %w[ 2 3 4 5 6 7 8 9 10 J Q K A ]
  session[:deck] = suits.product(values).shuffle!

  # deal cards
  session[:dealer_cards] = []
  session[:player_cards] = []
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop
  session[:player_cards] << session[:deck].pop
  session[:dealer_cards] << session[:deck].pop

  erb :game
end

get '/new_player' do
   erb :new_player
end

post '/new_player' do
   session[:player_name] = params[:player_name]
   redirect '/game'
end

get '/rules' do
  erb :rules
end

get '/about' do
  erb :about
end