#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'minority_game'
require 'minority_game/game/standard_mg'
require 'minority_game/player/learning_player'


module MinorityGame

  #=== A minority game with learning players.
  class LearningMinorityGame < StandardMinorityGame

    include MinorityGame

    DEFAULT_PLAYER_TYPE = "LearningPlayer"

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
      alpha = get_arghash(arg_hash, :alpha, DEFAULT_ALPHA)
      if alpha > 1.0 || alpha < 0.0
        STDERR.puts "invalid alpha: #{alpha}. it should be in range 0.0 - 1.0."
        return -1
      end
      @n.times do |id|
        @players.push(MinorityGame.const_get(player_type).new(
          id, @m, @s, @history_table, {alpha: alpha}))
      end
      return 0
    end
  end
end
