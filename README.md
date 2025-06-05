## Overview

This is an implementation of the classic Flappy Bird game is rendered entirely within a single **HLSL/CG shader**.
The gameplay physics and state transitions are controlled by a dedicated C# script (`FlappyBirdController.cs`), while all visuals are rendered directly through the shader.

![Movie_007](https://github.com/user-attachments/assets/03cb9bcd-1b69-4039-bcf9-748001f8210a)

---

## Features

### 🎮 Gameplay
- Classic Flappy Bird mechanics.
- Press space to make the bird fly.
- Pipes move from right to left.
- Score increases each time the bird passes a pipe.
- Game over triggered on collision or flying off-screen.

### 🖼️ Shader-Based Rendering
- Entire game rendered in one pass using a **custom unlit shader**: `FlappyBirdShader`.
- All textures (bird, background, pipes, title screen, game over screen, etc.) are displayed using **UV transformations**.
- No GameObjects or sprites used for visual representation—everything is computed in the fragment shader.

### 🧮 7-Segment Score Display
- Score is drawn using **7-segment digit rendering**.
- Numbers are generated procedurally in the shader using signed distance fields.

### 💫 Foil Effect
- A **dynamic foil effect** is applied to the entire scene using hue shifting based on view direction.
- Gives the appearance of a shiny, reflective foil card surface.

![Movie_003](https://github.com/user-attachments/assets/caa9b81d-f3e1-49ee-9e71-79a4d4d282b6)


### 🌀 UI Animations
- Title bobbing animation: uses `sin(time * speed) * amplitude`.
- "Press Space" pulsing animation: alpha oscillation using `sin(time * pulseSpeed)`.

### ⚙️ Physics & Control
- Controlled by a single C# script:
  - Handles input (space key).
  - Updates bird position using basic physics (gravity + jump force).
  - Manages pipe movement and resets.
  - Detects collisions and triggers game states.

---


## How It Works

### Shader Logic
All visual elements are drawn by checking whether a given pixel (UV coordinate) falls within the bounds of a particular object (e.g., bird, pipe, digit segment). This is done using signed distance field-like checks:

```hlsl
float drawHorizontalSegment(float2 uv, float y, float width, float height);
float drawVerticalSegment(float2 uv, float x, float yCenter, float width, float height);
```

These helper functions allow drawing of segmented digits and other shapes.

The **foil effect** is applied globally using a hue shift based on the tangent-space view direction:

```hlsl
fixed4 applyFoilEffect(float3 tangentSpaceViewDir, fixed4 baseColor)
```

### Game State Management
The game supports three main states:
1. **Menu** – Displays title and "Press Space" prompt with animated effects.
2. **Playing** – Active gameplay state; renders bird, pipes, and score.
3. **Game Over** – Shows the game over screen.

Each state renders different layers in the shader, determined by the `_GameState` property.
