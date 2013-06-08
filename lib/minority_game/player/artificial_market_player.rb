#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'minority_game'
require 'minority_game/player/standard_player'
require 'minority_game/player/learning_player'


module MinorityGame

  class ArtificialMarketPlayer < StandardPlayer

    #=== initialize method
    def initialize(id, m, s, history_table, arg_hash = nil, env = nil)
      super(id, m, s, history_table, arg_hash)
      @alpha = get_arghash(arg_hash, :alpha, DEFAULT_ALPHA)
      @env = env
    end

    #=== string method
    def to_s
      return "%22s%5d reward: %5d, decision: %s, strategy: %d, scores: " \
          "#{@strategy_scores}" % [self.class.name.split(/::/)[1], @id, @reward,
            @current_decision, @current_strategy]
    end
  end


  #=== same with LearningPlayer
  class ChartistPlayer < ArtificialMarketPlayer

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
  end


  #=== imitate the action that the player has highest reward.
  class HandImitatorPlayer < ArtificialMarketPlayer

    #=== initialize method
    def initialize(id, m, s, history_table, arg_hash = nil, env = nil)
      @id = id
      # initial history is determined at randomly.
      @history = 1.upto(m).inject("") { |str, i| str += $random.rand(2).to_s }
      @current_decision = -1
      @reward = 0
      # update speed of activity imitation
      @alpha = get_arghash(arg_hash, :alpha, DEFAULT_ALPHA)
      # learning speed of other player's probabilities of buying
      @beta = get_arghash(arg_hash, :beta, DEFAULT_BETA)
      # learning speed of other player's rewards
      @gamma = get_arghash(arg_hash, :gamma, DEFAULT_GAMMA)
      # reference to the game
      @env = env
      # probability of buying
      @pbuy = get_arghash(arg_hash, :pbuy, 0.5)
      # other player's probabilities of buying
      @pbuys = []
      # other player's rewards
      @rs = []
      @env.n.times { |i| @pbuys << @pbuy; @rs << 0 }
    end

    #=== determine whether buying or selling depending on pbuy
    def decision_make
      if $random.rand < @pbuy
        return @current_decision = 1
      else
        return @current_decision = 0
      end
    end

    #=== update the player with the result and the reward
    #result :: winner
    #reward :: reward for the player
    def update(result, reward)
      @reward += reward
      # update pbuys and rs
      @env.n.times do |i|
        @pbuys[i] = (1 - @beta) * @pbuys[i] + @beta * @env.decisions[i]
      end
      @env.n.times do |i|
        @rs[i] = (1 - @gamma) * @rs[i] + @gamma * @env.rewards[i]
      end
      # update pbuy with probability alpha
      if $random.rand < @alpha
        rsa = @rs.map { |i| i - @rs.min }
        index = nil
        if rsa.max <= 0 || rsa.max == rsa.min
          index = $random.rand(rsa.length)
        else
          index = propotional_sample_array(rsa)
        end
        if index.nil? || index < 0
          STDERR.puts "invalid index, #{rsa}, index: #{index}"
          exit
        end
        @pbuy = @pbuys[index]
      end
      @history = @history[1..@history.length - 1] + result.to_s
    end

    #=== string method
    def to_s
      # return "#{self.class.name.split(/::/)[1]}#{@id} reward: #{@reward}, " +
        # "decision: %s, probability of buying: #{@pbuy}"
      return "%22s%5d reward: %5d, probabilities of buying: #{@pbuy}" %
        [self.class.name.split(/::/)[1], @id, @reward]
    end
  end


  #=== imitate the strategy that the player has highest reward.
  class StrategyImitatorPlayer < ArtificialMarketPlayer

    #=== initialize method
    def initialize(id, m, s, history_table, arg_hash = nil, env = nil)
      @id = id
      # initial history is determined at randomly.
      @history = 1.upto(m).inject("") { |str, i| str += $random.rand(2).to_s }
      @current_decision = -1
      @current_strategy = 0
      @reward = 0
      # update speed of activity imitation
      @alpha = get_arghash(arg_hash, :alpha, DEFAULT_ALPHA)
      #super(id, m, s, history_table, arg_hash, env)
      # learning speed of other player's strategy
      @beta = get_arghash(arg_hash, :beta, DEFAULT_BETA)
      # learning speed of other player's rewards
      @gamma = get_arghash(arg_hash, :gamma, DEFAULT_GAMMA)
      # reference to the game
      @env = env
      # other player's strategies
      @ss = []
      # other player's rewards
      @rs = []
      @env.n.times do |i|
        @ss << (1..2 ** m).map { |c| $random.rand(2) }
        @rs << 0
      end
    end

    #=== determine the strategy of best score and make a decision
    def decision_make
      return @current_decision =
        @ss[@current_strategy][@env.history_table.index(@history)]
    end

    #=== update the player with the result and the reward
    #result :: winner
    #reward :: reward for the player
    def update(result, reward)
      @reward += reward
      # update ss and rs
      @env.n.times do |i|
        if @ss[i][@env.history_table.index(@history)] != result &&
            $random.rand < @beta
          @ss[i][@env.history_table.index(@history)] ^= 1
        end
      end
      @env.n.times do |i|
        @rs[i] = (1 - @gamma) * @rs[i] + @gamma * @env.rewards[i]
      end
      # update pbuy with probability alpha
      if $random.rand < @alpha
        rsa = @rs.map { |i| i - @rs.min }
        index = nil
        if rsa.max <= 0 || rsa.max == rsa.min
          index = $random.rand(rsa.length)
        else
          index = propotional_sample_array(rsa)
        end
        if index.nil? || index < 0
          STDERR.puts "invalid index, #{rsa}, index: #{index}"
          exit
        end
        @current_strategy = index
      end
      @history = @history[1..@history.length - 1] + result.to_s
    end
  end

  #=== may be implemented in futre :D
  class PerfectPredictorPlayer < ArtificialMarketPlayer
  end
end
