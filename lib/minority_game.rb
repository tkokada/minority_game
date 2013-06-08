#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

module MinorityGame

  # Constants

  # memory size
  DEFAULT_M = 3
  # number of players
  DEFAULT_N = 201
  # number of strategies
  DEFAULT_S = 3
  # number of trials
  DEFAULT_T = 100

  # learning speed of the agent
  DEFAULT_ALPHA = 0.8
  # learning speed of the agent
  DEFAULT_BETA = 0.2
  # learning speed of the agent
  DEFAULT_GAMMA = 0.5

  #=== create a binary string for the number.
  #for example, convert 7 to "00111".
  #n :: the converted number.
  #ref :: determine the digit.
  #returned_value :: binary string.
  def get_binary_string(n, ref)
    bs = n.to_s(2)
    bs = "0#{bs}" while bs.length < (ref).to_s(2).length - 1
    return bs
  end

  #=== get a value from arguments hash.
  #arg_hash :: hash including argument names as the key, argument value as the
  #value.
  #s :: symbol for the value
  #default :: default value
  #returned_value :: argument value
  def get_arghash(arg_hash, s, default)
    return default if arg_hash.nil? || !arg_hash.kind_of?(Hash)
    return (v = arg_hash[s]).nil? ? default : v
  end

  #=== propotional sample method for an array
  #a :: an array
  #returned_value :: On success, it returns the matched index. On error, it
  #returns -1.
  def propotional_sample_array(a)
    r, sum = $random.rand * a.inject(:+), 0.0
    a.length.times.each do |i|
      sum += a[i]
      return i if r < sum
    end
    return - 1
  end

  module_function :get_binary_string, :get_arghash, :propotional_sample_array
end
