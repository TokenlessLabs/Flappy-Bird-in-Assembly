# Floppy Ducc

A Flappy Bird-inspired game developed in **x86 Assembly Language** as a **Computer Organization and Assembly Language (COAL) project**.

The game challenges the player to control a duck, avoid randomly generated pillars, and achieve the highest possible score. The project was implemented at a low level using x86 Assembly, with custom graphics, keyboard and timer interrupts, game physics, collision detection, scoring, sound, and process management.

## Gameplay

The objective is to avoid the pillars and survive for as long as possible while increasing your score.

The game features:

- Floppy ducc character
- Moving pillar obstacles
- Gravity-based movement
- Collision detection
- Score tracking
- Increasing difficulty
- Pause and resume functionality
- Restart and retry options
- Custom background and cloud graphics
- Custom title and information screens
- Background music
- Keyboard interrupt handling
- Timer interrupt handling
- Separate processes for gameplay and music

The game progressively becomes more difficult as the player successfully passes pillars by reducing the game delay.

## Controls

| Key | Action |
|---|---|
| `SPACE` | Flap / move upward |
| `ESC` | Pause the game |
| `R` | Resume / retry |
| `E` | Return to title screen |
| `Q` | Quit the game |
| `Any Key` | Start / continue |

## Technical Overview

The project is written entirely in **x86 Assembly Language** and runs in DOS text mode.

### Graphics

The game directly manipulates video memory at `0xB800` to render its graphics. A screen buffer is used to construct frames before copying them to video memory.

Custom graphics were implemented for:

- Duck sprites
- Clouds
- Pillars
- Ground
- Background
- Title screen
- Pause screen
- Death screen

### Game Physics

The duck's movement is controlled using a velocity variable. Gravity continuously affects the duck's vertical position, while pressing `SPACE` gives the duck an upward velocity.

This creates the core flapping mechanic of the game.

### Obstacles and Difficulty

Pillars move across the screen toward the player. Their heights and gaps are generated with varying values to provide different obstacle configurations.

The score increases whenever the player successfully passes a pillar. As the score increases, the game delay is reduced, gradually increasing the difficulty.

### Collision Detection

The game continuously checks the duck's position against the pillar positions. When the duck collides with an obstacle or reaches the ground, the death state is triggered and the death screen is displayed.

### Interrupts

The project makes use of low-level interrupt handling, including:

- Keyboard interrupt for player input
- Timer interrupt for game timing
- Process switching and scheduling

The keyboard interrupt handles actions such as flapping, pausing, restarting, and quitting.

### Process Management

The game and music playback are implemented as separate processes. A PCB-based process management system is used to switch between them through the timer interrupt.

This allowed the game to run while background music played concurrently.

### Sound

Background music was integrated into the game using music data and low-level port communication. Music playback runs as a separate process alongside the game.

## Contributions

The project was developed collaboratively, with both team members contributing to multiple parts of the implementation. The following lists the primary areas each member worked on.

### Meerab Munir — `meerab munir / fastcel`

- Designed and implemented the title screen
- Worked on the title screen's visual layout and presentation
- Implemented and refined animated title-screen elements
- Contributed to the game's overall visual design and polish
- Worked on screen layouts, text placement, and presentation
- Assisted with integrating different game components
- Contributed to debugging and testing
- Helped refine gameplay and user experience
- Assisted with overall project integration and final polishing

### Shehryar Hassan — `shehryar789 / shehryar hassan`

- Contributed to the overall game design
- Designed and implemented core game mechanics
- Worked on duck movement and gravity/physics
- Contributed to pillar generation and movement
- Worked on collision detection and death conditions
- Contributed to scoring and difficulty progression
- Worked on keyboard controls and gameplay interaction
- Contributed to pause, restart, retry, and quit functionality
- Worked on interrupt handling and low-level system integration
- Added and integrated the background music
- Contributed to debugging, testing, and final polishing

### Collaboration

While responsibilities were divided into primary areas, many components of the project were developed and refined together. Both team members contributed to debugging, testing, integration, and polishing the final game.

## Concepts Demonstrated

This project demonstrates practical implementation of:

- x86 Assembly programming
- DOS interrupts
- BIOS services
- Direct video-memory manipulation
- Keyboard interrupts
- Timer interrupts
- Process scheduling
- PCB-based context switching
- Stack and register management
- Memory addressing
- Game loops
- Basic physics
- Collision detection
- Random number generation
- Double buffering
- Sprite rendering
- Animation
- Sound playback
- State management
- Low-level input handling

## Team

**Shehryar Hassan**  
`23L-0603`

**Meerab Munir**  
`23L-0971`

## Project Context

This project was developed for **Computer Organization and Assembly Language (COAL)**.

The purpose of the project was to apply concepts from computer architecture and x86 Assembly to the development of a complete interactive application. Instead of using a high-level game engine, the project implements its core systems at a low level, including graphics rendering, input handling, physics, collision detection, interrupts, process management, and audio playback.
