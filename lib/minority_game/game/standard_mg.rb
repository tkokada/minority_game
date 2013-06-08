#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'minority_game'
require 'minority_game/player/standard_player'


module MinorityGame

  #=== standard minority game.
  class StandardMinorityGame

    include MinorityGame

    # default player type, "StandardPlayer" and "RandomPlayer" are available.
    DEFAULT_PLAYER_TYPE = "StandardPlayer"

    # players
    attr_reader :players
    # all patterns of the history.
    attr_reader :history_table
    # length of the history
    attr_reader :m
    # number of the player (odd number)
    attr_reader :n
    # number of the stored strategies
    attr_reader :s
    # history of past winner
    attr_reader :winner_history
    # history of the number of past winner
    attr_reader :n_winner_history
    # history of gini
    attr_reader :gini_history

    #=== initialize method.
    #m :: length of the history
    #n :: number of the player (must be odd number)
    #s :: number of the stored strategies
    #randseed :: random seed
    #arg_hash :: storing arguments as follows
    #player_type: :: specify the player class name
    #winner_reward: :: a reward that winners obtain
    #loser_reward: :: a reward that losers obtain
    def initialize(m, n, s, randseed = nil, arg_hash = nil)
      $random = randseed.nil? ? Random.new : Random.new(randseed)
      if m < 1
        STDERR.puts "invalid history length. m: #{m}"
        exit
      end
      @m = m
      if n % 2 == 0 || n < 1
        STDERR.puts "number of players must be odd number! n: #{n}"
        exit
      end
      @n = n
      if s < 1
        STDERR.puts "invalid strategy length. s: #{s}"
        exit
      end
      @s = s

      # initialize history table with all combination patterns of m.
      @history_table = []
      (2**@m).times { |i| @history_table.push(get_binary_string(i, 2**@m)) }

      # initialize players
      @players = []
      if setup_player(arg_hash) < 0
        exit
      end

      @winner_history = []
      @n_winner_history = []
      @winner_reward = get_arghash(arg_hash, :winner_reward, 1)
      @loser_reward = get_arghash(arg_hash, :loser_reward, -1)
      @gini_history_interval = get_arghash(arg_hash, :gini_history_interval, 10)
      @gini_history = []
    end

    #=== examine the game with t times.
    #t :: number of execution
    def examine(t = 1)
      t.times do |ti|
        d = @players.map { |a| a.decision_make }
        winner = 1
        # select the winner making the fewer dicision.
        if (c = d.inject(0) { |w, i| i == 0 ? w + 1 : w }) < d.length - c
          winner = 0
        end
        @winner_history.push(winner)
        @n_winner_history.push(winner == 0 ? c : d.length - c)
        @players.each do |p|
          p.update(winner, get_reward(winner, p.current_decision))
        end
        if ti % @gini_history_interval == 0
          @gini_history.push(get_gini)
        end
      end
    end

    #=== calculate a gini coefficient of player's reward.
    #returned_value :: gini coefficient
    def get_gini
      rewards = @players.map { |p| p.reward }.sort
      n = rewards.length
      rewards = rewards.map { |r| r - rewards.min }
      sum = 0.0
      n.times { |i| n.times { |j| sum += (rewards[i] - rewards[j]).abs } }
      return sum / 2.0 / n**2 / (rewards.inject(:+) * 1.0 / n)
    end

    #=== get a reward
    #winner :: winner decision from 0 or 1
    #decision :: a decsion of a player
    #returned_value :: winner reward or loser reward
    def get_reward(winner, decision)
      return winner == decision ? @winner_reward : @loser_reward
    end

    private
    #=== initialize players.
    #arg_hash :: same hash object with intialize method.
    #returned_value :: On success, it returns zero. On error, it returns -1.
    def setup_player(arg_hash)
      player_type = get_arghash(arg_hash, :player_type, DEFAULT_PLAYER_TYPE)
      unless MinorityGame.const_defined?(player_type)
        STDERR.puts "invalid player type. : #{player_type}"
        return -1
      end
      @n.times do |id|
        @players.push(MinorityGame.const_get(player_type).new(
          id, @m, @s, @history_table))
      end
      return 0
    end
  end
end
