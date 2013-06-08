#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'minority_game'


module MinorityGame

  #=== player of standard minority game.
  class StandardPlayer

    include MinorityGame

    # newest decision
    attr_accessor :current_decision
    # history of the determination
    attr_accessor :history
    # identifier
    attr_reader   :id
    # total reward
    attr_accessor :reward
    # strategy candidates that this player can use
    attr_accessor :strategies
    # scores each strategy
    attr_accessor :strategy_scores
    # current strategy history
    attr_accessor :strategy_history
    # history of scores each strategy
    attr_accessor :strategy_scores_history

    #=== initialize method
    #id :: identifier of the player
    #m :: length of the history
    #s :: number of the stored strategies
    #history_table :: history table to check past win
    #arg_hash :: not used
    def initialize(id, m, s, history_table, arg_hash = nil)
      @id = id
      # initial history is determined at randomly.
      @history = 1.upto(m).inject("") { |str, i| str += $random.rand(2).to_s }
      # initialize strategies at randomly.
      @strategies = []
      1.upto(s).map { |i| $random.rand(2**2**m) }.each do |r|
        @strategies.push(history_table.zip(get_binary_string(r, 2**2**m)
                                           .split(//).map { |j| j.to_i }))
      end
      @strategy_scores = @strategies.length.times.map { |i| 0 }
      @strategy_history = []
      @strategy_scores_history = @strategies.length.times.map { |i| [] }
      @current_strategy = 0
      @current_decision = -1
      @reward = 0
    end

    #=== determine the strategy of best score and make a decision
    #returned_value :: current dicision
    def decision_make
      smax = @strategy_scores.max
      # if uses Array#sample, it destroys randseed.
      @current_strategy = (
        samples = @strategy_scores.length.times.inject([]) { |c, i|
          @strategy_scores[i] == smax ? c + [i] : c }
                          )[$random.rand(samples.length)]
      return @current_decision = @strategies[@current_strategy]
        .assoc(@history)[1]
    end

    #=== update the player with the result and the reward
    #result :: winner
    #reward :: reward for the player
    def update(result, reward)
      @strategy_scores[@current_strategy] += reward
      @reward += reward
      @history = @history[1..@history.length - 1] + result.to_s
      @strategy_history.push(@current_strategy)
      @strategy_scores.length.times.each do |i|
        @strategy_scores_history[i].push(@strategy_scores[i])
      end
    end

    #=== string method
    def to_s
      return "player%5d reward: %5d, decision: %s, strategy: %d, scores: " \
          "#{@strategy_scores}" % [@id, @reward, @current_decision,
            @current_strategy]
    end
  end


  #=== player with random decision make.
  class RandomPlayer

    include MinorityGame

    # newest decision
    attr_accessor :current_decision
    # identifier
    attr_reader :id
    # total reward
    attr_accessor :reward

    #=== initialize method
    #id :: identifier of the player
    #m :: not used
    #s :: not used
    #history_table :: not used
    #arg_hash :: not used
    def initialize(id, m, s, history_table, arg_hash = nil)
      @id = id
      @current_decision = -1
      @reward = 0
    end

    #=== determine the strategy of best score and make a decision
    #returned_value :: current dicision
    def decision_make
      return @current_decision = $random.rand(2)
    end

    #=== update the player with the result and the reward
    #result :: winner
    #reward :: reward for the player
    def update(result, reward)
      @reward += reward
    end

    #=== string method
    def to_s
      return "player%5d reward: %5d, decision: %s" % \
          [@id, @reward, @current_decision]
    end
  end
end
