#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'minority_game'
require 'minority_game/player/standard_player'


module MinorityGame

  class LearningPlayer < StandardPlayer

    # learning speed to update the strategy table
    attr_reader :alpha

    #=== initialize method
    def initialize(id, m, s, history_table, arg_hash=nil)
      super(id, m, s, history_table, arg_hash)
      @alpha = get_arghash(arg_hash, :alpha, DEFAULT_ALPHA)
    end

    #=== update the player with the result and the reward
    #result :: winner
    #reward :: reward for the player
    def update(result, reward)
      @strategy_scores[@current_strategy] += reward
      @reward += reward
      if reward < 0 and $random.rand < @alpha
        @strategies[@current_strategy][@strategies[@current_strategy]
            .index([@history, @current_decision])][1] ^= 1
      end
      @history = @history[1..@history.length - 1] + result.to_s
      @strategy_history.push(@current_strategy)
      @strategy_scores.length.times.each do |i|
        @strategy_scores_history[i].push(@strategy_scores[i])
      end
    end

    #=== string method
    def to_s
      return "%s%5d reward: %5d, decision: %s, strategy: %d, scores: " \
          "#{@strategy_scores}" % [self.class.name.split(/::/)[1], @id, @reward,
            @current_decision, @current_strategy]
    end
  end
end
