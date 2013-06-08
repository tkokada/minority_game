#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'minority_game'
require 'minority_game/game/standard_mg'
require 'minority_game/player/artificial_market_player'


module MinorityGame

  #=== standard minority game.
  class ArtificialMarketGame < StandardMinorityGame

    include MinorityGame

    # current dicisions of all players
    attr_reader :decisions
    # current rewards of all players
    attr_reader :rewards
    # history of average rewards
    attr_reader :average_rewards_history

    #=== initialize method.
    #m :: length of the history
    #n :: number of the player (odd number)
    #s :: number of the stored strategies
    #randseed :: random seed
    #arg_hash :: storing arguments as follows
    #player_type: :: specify the player class name
    #winner_reward: :: a reward that winners obtain
    #loser_reward: :: a reward that losers obtain
    #number_of_ch: :: number of agent Chartis(Ch)
    #number_of_hi: :: number of agent Hand imitator(HI)
    #number_of_si: :: number of agent Strategy imitator(SI)
    #number_of_pp: :: number of agent Perfect predictor(PP)
    #alpha: :: learning speed
    #beta: :: learning speed of other players model
    #gamma: :: updating speed of reward
    def initialize(m, n, s, randseed, arg_hash = nil)
      super(m, n, s, randseed, arg_hash)
      @decisions = []
      @rewards = []
      @average_rewards_history = {ChartistPlayer: [],
                                  HandImitatorPlayer: [],
                                  StrategyImitatorPlayer: []}
    end

    #=== examine the game with t times.
    #t :: number of execution
    def examine(t = 1)
      t.times do |ti|
        d = @players.map {|a| a.decision_make}
        winner = 1
        if (c = d.inject(0) {|w, i| i == 0 ? w + 1 : w}) < d.length - c
          winner = 0
        end
        @winner_history.push(winner)
        @n_winner_history.push(winner == 0 ? c : d.length - c)
        @decisions.clear
        @rewards.clear
        @players.each do |p|
          @decisions.push(p.current_decision)
          @rewards.push(get_reward(winner, p.current_decision))
        end
        @players.each {|p| p.update(winner,
                                    get_reward(winner, p.current_decision))}
        if ti % 10 == 0
          @gini_history.push(get_gini)
          ar_ch = get_average_reward_with_type("ChartistPlayer")
          ar_hi = get_average_reward_with_type("HandImitatorPlayer")
          ar_si = get_average_reward_with_type("StrategyImitatorPlayer")
          # @average_rewards_history[:ChartistPlayer].push(0.0)
          # @average_rewards_history[:HandImitatorPlayer].push(ar_hi - ar_ch)
          # @average_rewards_history[:StrategyImitatorPlayer].push(ar_si - ar_ch)
          @average_rewards_history[:ChartistPlayer].push(ar_ch)
          @average_rewards_history[:HandImitatorPlayer].push(ar_hi)
          @average_rewards_history[:StrategyImitatorPlayer].push(ar_si)
        end
      end
    end

    #=== get the distribution of the average of the reward for specified type
    #player.
    #type :: a class name of the player.
    #returned_value :: mean and standard diviation
    def get_average_distribution_reward_with_type(type)
      unless MinorityGame.const_defined?(type)
        STDERR.puts "invalid type. #{type}"
        return 0.0, 0.0
      end
      a = @players.inject([]) { |s, p|
        p.instance_of?(MinorityGame.const_get(type)) ? s << p : s }
      if a.length > 0
        m = a.inject(0.0) { |sum, p| sum += p.reward } / a.length
        d = a.inject(0.0) { |sum, p| sum += ((p.reward - m)**2)} / (a.length)
        return m, d
      else
        return 0.0, 0.0
      end
    end

    #=== get the average of the reward for specified type player.
    #type :: a class name of the player.
    #returned_value :: mean
    def get_average_reward_with_type(type)
      unless MinorityGame.const_defined?(type)
        STDERR.puts "invalid type. #{type}"
        return 0.0
      end
      a = @players.inject([]) { |s, p|
        p.instance_of?(MinorityGame.const_get(type)) ? s << p : s }
      if a.length > 0
        return a.inject(0.0) { |sum, p| sum += p.reward } / a.length
      else
        return 0.0
      end
    end

    private
    #=== initialize players.
    #arg_hash :: same hash object with intialize method.
    #returned_value :: On success, it returns zero. On error, it returns -1.
    def setup_player(arg_hash)
      number_of_ch = get_arghash(arg_hash, :number_of_ch, 0)
      number_of_hi = get_arghash(arg_hash, :number_of_hi, 0)
      number_of_si = get_arghash(arg_hash, :number_of_si, 0)
      number_of_pp = get_arghash(arg_hash, :number_of_pp, 0)

      alpha = get_arghash(arg_hash, :alpha, DEFAULT_ALPHA)
      beta = get_arghash(arg_hash, :beta, DEFAULT_BETA)
      gamma = get_arghash(arg_hash, :gamma, DEFAULT_GAMMA)

      unless @n == number_of_ch + number_of_hi + number_of_si + number_of_pp
        @n = number_of_ch + number_of_hi + number_of_si + number_of_pp
      end
      if @n % 2 == 0
        STDERR.puts "number of players must be odd number! n: #{@n}"
        exit
      end

      id = 0
      number_of_ch.times do |i|
        @players.push(Module.const_get("ChartistPlayer")
                      .new(i, @m, @s, @history_table, {alpha: alpha}, self))
      end
      id += number_of_ch
      number_of_hi.times do |i|
        @players.push(Module.const_get("HandImitatorPlayer")
                      .new(i + id, @m, @s, @history_table,
                           {alpha: alpha, beta: beta, gamma: gamma, pbuy: 0.5},
                           self))
      end
      id += number_of_hi
      number_of_si.times do |i|
        @players.push(Module.const_get("StrategyImitatorPlayer")
                      .new(i + id, @m, @s, @history_table,
                           {alpha: alpha, beta: beta, gamma: gamma}, self))
      end
      ## may be implemented in future.
      # id += number_of_si
      # number_of_pp.times do |i|
        # @players.push(Module.const_get("PerfectPredictorPlayer")
                      # .new(i + id, @m, @s, @history_table, nil, self))
      # end
      return 0
    end
  end
end
