# Chi War API Server

Chi War is a character and campaign manager for the tabletop roleplaying game (RPG) called Feng Shui 2, by Robin D. Laws.

This repository is the backend API server containing the database and JSON API that communicates with the frontend client `shot-client`, which is written with NextJS and React.

It is currently deployed on https://fly.io/ at https://chiwar.net/.

## About

The intention is to be a full manager for a gamemaster's campaign of Feng Shui 2. The game is a tabletop roleplaying game similar to Dungeons and Dragons, but inspired by Hong Kong action movies.

A game of Feng Shui 2 involves a player known as the Gamemaster, who runs the campaign, and a group of players who play characters having adventures. The characters have various statistics such as "Guns", "Martial Arts", "Defense", or "Wounds", and they have various associated items including weapons and talents.

Each player controls a single character, while the Gamemaster controls all the antagonists and friendly characters not controlled players.

### Note

Feng Shui 2 doesn't have a ton of players, but it's my favorite RPG, and I've been running at least one campaign of Feng Shui 2 continuously since roughly 2016. I built this app for a few reasons:

- to manage my own campaign, tracking details of fights and characters;
- to allow my players a single place to track their characters and keep them up to date;
- as a tool to learn React and NextJS.

I chose to build the app as an API server only because Ruby on Rails is my primary strength as a developer, and I wanted to learn some new frontend skills on a big project.

## Features

### Characters

The main thing a player is concerned with in a game of Feng Shui 2 is their character. A character has many stats and attributes, but player characters are built from pre-designed archetypes such as "Martial Artist", "Ninja", "Private Investigator", or "Old Master". A character has a set of skills called "Action Values", such as "Guns", "Martial Arts", "Defense", and "Toughness".

Aside from Player Characters, there are several other categories of character:

- Uber-Boss, the toughest villain type in the game
- Boss, a powerful antagonist your characters would battle at the climax of an adventure
- Featured Foes, the enforcers, henchmen, and powerful bad guys your characters fight on the way to the Boss
- Mooks, the nameless foot-soldiers, ninjas, army men, or assassins your characters fight in waves. Think John Wick or Chow Yun-Fat facing hordes of killers in matching outfits!
- Allies, the non-player characters who might be allied with your Player Characters.

Each type of character has different relevant statistics, so the system was built to distinguish between them, and show the relevant attributes where appropriate.

### Vehicles

Feng Shui 2 has a fantastic vehicle-chase system, and Vehicles are _very_ similar to Characters in many respects. I almost built the vehicles as a polymorphic system, with just a "type" field to distinguish between a Character and a Vehicle. In the end I decided it would make more sense for Character and Vehicle to have their own tables, because there are ultimately a lot of differences which are easier to track that way.

### Fights

In Feng Shui 2, your session will consist of roleplaying scenes, where characters talk to each other, and fights. The roleplaying scenes don't need mechanical details tracked, but in a fight there are a lot of things to keep track of.

#### Shots

Feng Shui 2 has a unique initiative system, very different than Dungeons and Dragons and other common RPGs.

A fight is tracked on a Shot Counter, which is a series of numbers counting down (usually from 20 or so) to zero. The characters roll initiative, which determines their starting shot. The speedy Ninja might start on shot 18, while the Sorcerer and the lumbering Big Bruiser start on shot 14, and the enemy Mook Ninjas start on shot 9.

The fight begins on the highest shot, and all characters on that shot take actions, in order. When a character takes an action, they spend a certain number of shots--3 shots for most actions. If the Ninja is on shot 18 and makes an attack, he spends 3 shots and moves down to shot 15.

So the Fight model in the app was built using a join table called `fight_characters` to join the `fights` table with the `characters` table and the `vehicles` table. `fight_characters` also has a field to identify which `shot` it represents.

If the Ninja is on shot 15, his `character` will be associated with the `fight` through a `fight_characters` record with a `shot` attribute of `15`.

### Schticks

### Weapons

## Discord Bot

The app also serves as a backend for a Discord bot, where a group running a game of Feng Shui 2 could use Discord slash commands to show the current status of a fight, and perform simple management of their characters.

## Dependencies

The app was built targeting the following versions:

- Ruby version 3.1.0
- Rails version 7.0.4
- Postgresql 14.6
- Redis 7.07

## Configuration

To configure the app, you'll need some secret keys:

- a Discord token and client
- a Devise JWT secret key, to encrypt the JSON Web Token
- SMTP credentials to send emails to users

To edit the credentials, use the `rails credentials:edit` command:

```
EDITOR=vim rails credentials:edit --environment production
```

The structure of the credentials is as follows:

```
discord:
  token: ...
  client_id: ...
devise_jwt_secret_key: ...
smtp:
  user_name: ...
  password: ...
```
