Game Design Document: Balen Mercenaries

Lead Game Designer: Gemini
Engine: Godot 4.6
Genre: Top-Down 2D Sandbox Action RPG / Life & Mercenary Sim
Inspirations: Kenshi, The Legend of Zelda (Combat Feel), Project Zomboid (Time Management), Mount & Blade

1. Executive Summary & Core Pillars

Balen Mercenaries is a top-down, gridless 2D pixel-art sandbox action RPG where the player's life is their only currency, and time is the ultimate adversary. Starting as a 15-year-old youth who has just reached the age of military eligibility, the player is thrown into a fully autonomous, reactive fantasy world divided into four distinct territories.

Core Pillars:

Absolute Autonomy, Infinite Paths: The player is never forced down a set path. They can live as an honorable mercenary, a wealthy merchant, a master thief, or an illegal venture capitalist.

The Single-Threaded Control Rule: The player only controls their character. Even if they own global merchant fleets or run vast mercenary guilds, they operate on the ground, feeling the immediate physical consequences of their strategic decisions.

The Unrelenting Clock (Aging & Permadeath): Time passes dynamically. The player ages, starting from youth (Age 15) and progressing towards unavoidable death from natural old age (Age ~75).

Reactive World Ecosystem: The world does not wait for the player. NPCs have memories, complete their own daily loops, succeed, fail, wage war, and die, while the player adapts to the shifting balance of power.

2. Game Feel & Kinesthetics

Using the principles of virtual sensation, we categorize our moment-to-moment gameplay to guarantee a tactile, physical link between the player and their avatar.

+-------------------------------------------------------------+
|                         PLAYER INPUT                        |
|                     (Keyboard & Mouse)                      |
+------------------------------+------------------------------+
                               |
                               v
+------------------------------+------------------------------+
|                         RESPONSE MAP                        |
|      - Acceleration and Friction Curves                     |
|      - Action Combat Attack/Decay/Sustain/Release Envelopes |
+------------------------------+------------------------------+
                               |
                               v
+------------------------------+------------------------------+
|                       SIMULATED SPACE                       |
|        - Reactive collisions with dynamic tilemaps          |
|        - Weight metrics based on current age/skills         |
+------------------------------+------------------------------+
                               |
                               v
+------------------------------+------------------------------+
|                        POLISH & JUICE                       |
|    - Footstep dust, camera shake, dynamic visual aging       |
+-------------------------------------------------------------+


A. Real-Time Control & Input Mapping

Movement Model: Gridless, 360-degree analog or 8-directional keyboard movement.

The Velocity Envelope: To prevent a "stiff" or "floaty" feel, we implement a physics-based velocity model:

Velocity_New = Velocity_Current * (1 - Friction * Delta_Time) + Acceleration * Delta_Time


Where Friction is the terrain coefficient, and Acceleration is modified by the player's physical age and athletic skills.

B. Real-Time Action Combat (Zelda-Style)

Combat is real-time, fluid, and highly dependent on positioning and timing.

Melee Combat: Dynamic, directional swinging utilizing active collision hitboxes (rather than tab-targeting). Swing timings use an ADSR (Attack, Decay, Sustain, Release) envelope:

Heavy Weapons (e.g., Greatswords): Long attack phase requiring high anticipation; wide sweeping hitboxes that can hit multiple enemies; massive knockback.

Light Weapons (e.g., Daggers): Near-instantaneous attack phases, high recovery rates, minimal reach.

Ranged Combat: Utilizes manual aiming with mouse input. Projectiles possess real physical velocity, gravity drop, and can be deflected or blocked by shields.

Magic Abilities: Spells require dynamic casting states. Pressing and holding the casting key charges the spell (leaving the caster vulnerable). Magic is highly elemental, interacting directly with the environment (e.g., lightning deals extra damage to wet targets, fire spreads on dry grass).

C. Polish & Juice

Visual Aging: The character's sprite sheet dynamically alters color palettes (hair graying) and posture/animations (wrinkling, slight slouching in old age).

Dynamic Camera: The camera features subtle dead-zones that adjust based on movement speed. During high-intensity combat, the camera zooms in slightly; during open-world travel or merchant trade, it pulls back to show regional context.

Aural Feedback: Footstep sound effects dynamically shift from light leather taps (youth, light armor) to heavy metallic thuds (middle-age, heavy plate), to slightly dragged scuffs (old age).

3. Gameplay Mechanics

A. Skills System (Learn by Doing)

Skills are split into distinct categories and improve dynamically with use:

Skill Category

Primary Skills

Mechanics & Dynamic Progression

Active/Combat

Swords, Bows, Magic, Shields

Usage increases damage multiplier, swing velocity, spell charge speed, and recovery.

Passive

Athletics, Sneak, Toughness

Athletics reduces stamina drain; sneak shrinks detection radiuses; toughness mitigates damage.

Weapon Mastery

Parry, Guard Break, Precision

Unlocks unique tactical combat modifiers automatically upon hitting skill thresholds.

Trade & Logic

Barter, Appraisal, Smuggling

Reduces purchase prices, identifies item quality, and lowers guard detection rates.

B. Dynamic Aging & Time Scale System

The game is built for long-form immersion, designed around a full 120-real-hour lifecycle.

Lifespan Parameters:

Starting Age: 15 years old.

Natural Death Age: ~75 years old.

Total Playable Lifespan: 60 in-game years.

In-Game Calendar: Each year consists of 60 days.

Time Calculation (1x Active Play Speed):

Total_Play_Time_Hours = 120
Total_In_Game_Years = 60
Real_Time_Per_Year = 2 Hours (120 Minutes)
Real_Time_Per_Day = 2 Minutes (120 Seconds)


Time Control (Project Zomboid-Style):

Standard Speed (1x): Time moves at exactly 120 seconds per in-game day. This is the forced speed during combat, movement, trading, and any active world engagement.

Fast Forward: Time speed can be increased (e.g., 5x, 10x, 50x) only when the player character is in an idle state (e.g., waiting at a tavern, resting, reading books to train logic) or sleeping. Any nearby danger or sudden NPC interaction immediately drops the game speed back to 1x.

Physical Aging Progression:

Youth (15–35): Maximum stamina recovery, high agility, fast physical and active skill growth.

Middle-Age (36–55): Balanced stats. Peak mental and trade skill growth. Physical stats stabilize; resistance to damage slightly increases.

Elderly (56–75): Physical attributes begin to decay. Maximum movement speed and carrying capacity are penalized. However, high-level mastery skills act as structural buffers to keep the character deadly.

4. World Ecology & Autonomous AI

A. The Four Territories

The game world consists of four distinct sovereign powers:

Territory A (The Merchant Core): High security, sprawling markets, strict laws. Best for traders, worst for thieves.

Territory B (The Shattered Barony): Fractured, warlike lords. Infinite mercenary contracts, high danger, volatile borders.

Territory C (The Wildlands): Monster infestations, lawless, dense resources. Best for monster hunters and smugglers.

Territory D (The Technocracy/High-Cult): Rigid, secretive, high-tech/magic. Extreme entry requirements, powerful gear, high risk of execution.

B. Reactive NPC Dialogue & Memory

NPC interactions are driven by simple, branching dialogue trees (similar to Kenshi), heavily influenced by dynamic world variables and actor memory.

Memory Integration: NPCs store a history profile of the player.

# Godot 4.6 Memory Vector
var npc_memory = {
    "player_trust": 0.8,       # Range: -1.0 to 1.0
    "last_interaction": "theft",
    "has_helped_faction": true,
    "grudge_level": 5
}


Reactive Branches: Dialogue options are conditionally visible based on player statistics, faction reputations, local world events, and past memories.

Example: A local merchant will refuse to talk to you or offer a hostile choice tree if your player_trust is negative or if they remember you attempting to pickpocket them in the past.

5. Economy, Ownership & Guilds

A. Ventures & Real Estate

Properties: Players can buy houses, taverns, or warehouses in towns. Taverns generate daily passive income, which can be stored in town vaults.

Illegal Ventures: Players can invest in black-market operations (smuggling dens, thief rings, bandit outposts). These generate massive income but risk structural destruction by regional guards if discovered.

B. Contracts & Guild Affiliation

Contracts: Dynamically generated at town notice boards based on regional state (e.g., if Barony B is at war, mercenary contracts triple in value).

Guild Leadership: The player can climb the ranks of factions (like the Mercenary Guild). While they can command units to patrol a territory, they never take manual control of them in battle. They must fight on the field alongside their brothers-in-arms.

6. Death & Game Over (Hard Restart)

Death in Balen Mercenaries is permanent and absolute. There are no ancestral legacy mechanics or heirloom transfers. When your character dies—whether in battle or from natural old age at 75—it is a definitive Game Over.

The Epitaph Screen

To honor the player's 120-hour journey and provide a highly shareable social element, the game concludes with a stylized, comprehensive Epitaph Screen:

Dynamic Title/Alias: Generated based on your accomplishments (e.g., "The Merchant King of Balen", "The Banished Mage", or "The Long-Lived Sellsword").

Visual Portrait: A snapshot of your character's sprite in their final moments, showcasing their age, gear, and scars.

Lifetime Metrics:

Years Lived: (e.g., "60 Years, 14 Days")

Gold Earned & Real Estate Valuation

Factions Controlled or Annihilated

Total Enemies Defeated (categorized by type)

Cause of Death: (e.g., "Old Age", "Felled by a Barony Executioner", "Poisoned")

Export/Share Action: A single-button "Share Story" option that formats this summary screen into a clean, highly aesthetic image file tailored for online forums (Reddit, Discord) and social media, allowing players to compare their mercenary legacies.