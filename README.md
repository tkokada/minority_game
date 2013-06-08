# Simple implementation of Minority Game in Ruby.
====

## Table Of Contents
---
* [Overview](#section_Overview)
* [QuickStart](#section_QuickStart)
* [Minority Game](#section_MinorityGame)
* [Standard Minority Game](#section_StandardMinorityGame)
* [Learning Minority Game](#section_LearningMinorityGame)
* [Artificial marcket](#section_ArtificialMarcket)
* [Document](#section_Document)

<a name="section_Overview"></a>
## Overview
---
This software is a simple implementation of [**Minority game**](#section_MinorityGame).
In the minority game, an odd number of players each must choose one of two choices independently at each turn. The players who end up on the minority side win. 

<a name="section_QuickStart"></a>
## QuickStart
---
This software works on **Ruby**. After installing **Ruby**, a sample in bin directory works simply as follows:

    ruby bin/standard_mg
    
`standard_minority_game` examines a simple game with 201 players by default. On success, you can check the inputs and outputs in the terminal.

    --- initial settings ---
    m: 3, n: 201, ptype: StandardPlayer, randseed: 0, s: 3, t: 100
    --- outputs ---
    mean winners: 92.8
    diviation winners: 5.238320341483519    average of winners: 94.8

If you want to change variables with arguments, please check them with -h option. 

    ruby bin/standard_mg -h
    
    Usage: standard_mg [options]
    -d, --debug                      debug option
    -m, --memory=MEMORY              specify a memory size of the number of the history that players store
    -n, --number=NUM_PLAYER          specify a number of the players
    -p, --player=PLAYER              specify a player type from 'StandardPlayer' or 'RandomPlayer'.
    -r, --randseed=RANDSEED          specify a random seed number.
    -s, --strategy=STRATEGY          specify a number of strateges that players have
    -t, --trial=TRIAL                specify a number of the trial thath the game is examined

For example, if you want to change the number of players,

    ruby bin/standard_mg -n 301

To check status of all players and the game, set -d option.

    ruby bin/standard_mg -n 301 -d


<a name="section_MinorityGame"></a>
## Minority game
---
Followings are the explanation of Minority game from [Wikipedia](http://en.wikipedia.org/wiki/El_Farol_Bar_problem).

>One variant of the El Farol Bar problem is the minority game proposed by Yi-Cheng Zhang and Damien Challet from the University of Fribourg. In the minority game, an odd number of players each must choose one of two choices independently at each turn.

>The players who end up on the minority side win. While the El Farol Bar problem was originally formulated to analyze a decision-making method other than deductive rationality, the minority game examines the characteristic of the game that no single deterministic strategy may be adopted by all participants in equilibrium. Allowing for mixed strategies in the single-stage minority game produces a unique symmetric Nash equilibrium, which is for each player to choose each action with 50% probability, as well as multiple equilibria that are not symmetric.

>The minority game was featured in the manga Liar Game. In that multi-stage minority game, the majority was eliminated from the game until only one player was left. Players were shown engaging in cooperative strategies.


<a name="section_StandardMinorityGame"></a>
## Standard minority game
---
`standard_mg` in bin directory is a simplest implementation of Minority game.


<a name="section_LearningMinorityGame"></a>
## Learning minority game
---
`learning_mg` in bin directory is almost same with `standard_mg`, but the players sometime learn and change their strategy with probability alpha.


<a name="section_ArtificialMarcket"></a>
## Artificial marcket
---
`artificial_marcket` is an implementation of a simple artificial marcket using this minority game. The implementation consists of three types of agent such as Chartist, Hand imitator and Strategy imitator. These agents have different strategies to determine `buy` or `sell` action.
Chartist sometime changes the strategy when the reward was negative.
Hand imitator learns actions from the other agents that have highest reward.
Stragegy imitator learns strategies from the other agents that have highest reward.
The program simply executes a game with different number of these agents. 

Following is an example of the artificial marcket with 3 chartists, 2 head imitators and 2 strategy imitators.

	ruby bin/artificial_marcket -c 3 -h 2 -i 2

The arguments of this game can be checked in the same way with `standard_mg`.

The details of these agent behavior are refered from [Izumi's paper](http://ci.nii.ac.jp/naid/110003176817). If you want to know the details, please check it.


<a name="section_Document"></a>
## Document
---
Rdoc document can be generated as follows:

	rake rdoc