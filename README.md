# FPGA Atari Project
  This is an implementation of the Atari breakout game that was implemented on a DE1-SoC FPGA development board. It was coded through the Verilog scripting language and provides users with a display as well as physical controls through the buttons and the switches on the board.

# How to Play
  Playing is simple start by making sure the reset switch (sw[1]) is flipped into the off position. Next you will be able to move the paddle to the edges of the screen without going past it. To do this use the buttons on the board button 1 (Key[1]) moves the paddle right and button 2 (Key[0]) moves the paddle left. If the ball collides with the block it will be removed from the screen when all blocks are gone you win. However if the ball gose off the screen you will lose causeing you to have to use the reset switch as stated before losing is indicated through the background changing colors to red.

# Visual implementations
Display: The visual screen display is 640x480 giving the user a clear picture of all objects at once.

Background: the dark blue baground gives a nice contrast to the other objects required for play allowing for a cleaner look.

Blocks: each row of blocks has a seaperate color from those surrounding them to better help the user distiquish progress through row destruction.

Paddle: the paddle is white so as to draw the users eye with its sharp contrast to the dark baground allowing the user to easily see where the paddle is at all times.

Ball: the ball is white to help indicate that the user can interact with it through the paddle as well as being an easy color to track visually.

Lose State: the baground shifts colors to red upon losing giving the user imeadiate feed back upon the fact that the game has concluded in a loss.

# Design Description
  Reset state

  Our reset state sets everything up when you flip SW[1]. When you flip it to the off position the game begins.

![IMG_2195](https://github.com/user-attachments/assets/590b6d7b-bddb-46f3-8d3d-8bdb1b978e9a)


Paddle logic 

  We had our positioning set up so when the game was in the restart stage the paddle would be in the direct center of the screen. We were able to do this by utilizing the formula: (SCREEN_WIDTH - PADDLE_WIDTH) / 2. This code allowed our  paddle to always be centered in the beginning of the game. We had the paddle move at a constant speed in either direction when the buttons were being pressed. It kept moving at the same speed until the button stopped being pressed or if it hit either of the walls that it was bound to.


![IMG_6337](https://github.com/user-attachments/assets/006985da-d90b-4c82-91c8-689ab4f2658d)

  For our paddle we connected the movement to the DE1-SOC FPGA development board. Using the code: if (!KEY[1]) – next_state  = MOVE_LEFT; allowed us to have KEY[1] be connected to the left movement of the paddle. 
![IMG_6338](https://github.com/user-attachments/assets/e91585fa-6c32-4888-90b8-a8250f533720)

  To have our paddle move right we used: else if (!KEY[0]) – next_state = MOVE_RIGHT;. This allowed Key[0] to move the paddle right when the button was activated. 
When neither of the buttons were being pressed down we had the next state point towards the idle state. This allowed the paddle to stay in the exact position that it was left in and so the paddle didn’t move constantly around the x axis of the screen. 

Ball Logic

![IMG_6329](https://github.com/user-attachments/assets/2fccc07e-df8c-47ea-874a-824b43098674)

  We coded the ball so it would move at a constant speed in the x and y direction. We have the ball coded so it stays in bounds of the screen on all sides except the bottom because if it goes past the paddle the ball disappears and the lose state is activated. 

![IMG_6331](https://github.com/user-attachments/assets/76fc7e23-19e2-4ecb-a75e-90e95804f5f3)

  At one point in time we had it so the ball wouldn’t go through the paddle. It was at a point where it would stay on top of the paddle unable to fall through it at any given time. 

Brick logic

  We set our bricks up in 5 rows and 10 columns per row. We color coordinated each row to help the user know how far they have gotten in each column. The colors going from the very top to bottom are red, orange, yellow, green, and blue. 
![IMG_6339](https://github.com/user-attachments/assets/f5c44afa-9363-432d-b6c2-6db3a9197222)



  We coded our bricks so once the ball collided with each individual brick, said brick would disappear. We also added a brick counter which kept track of how many of the fifty initial bricks were left. After all of the bricks were gone the win state was supposed to be activated.



Lose State

![IMG_2186](https://github.com/user-attachments/assets/f3f84a9d-5751-4055-9b9c-973ecf756db0)

For our game we implemented a simple lose state where once you lost the screen would go red leaving the paddle and bricks in the lost position and condition they were last in.


# Results 

In the end we managed to successfully set up and have paddle movement that moved cleaning throughout the screen and stayed in bounds of the screen at all times. We also had all of our bricks in nice clean rows and they would disappear when they made contact with the ball. Our lose state also worked flawlessly ending the game after the ball went past the paddle. We had a reset state which when switch one was flipped on would reset all the bricks and center the paddle and the ball. 


Issues
The ball would successfully hit the bricks and break them, however we never managed to get the ball to reverse its direction after it hit a brick so it just kept going until it got stuck in a corner. Also we broke the code that worked for the ball touching the paddle and in the end it went back to the original issue of the ball going through the paddle.

# Conclusion 
In this project we successfully learn how to code game mechanics and how to utilize the DE1-SOC FPGA development board with our code. We also succeeded in many areas, only failing to fully implement a working game because we were unable to succeed in getting the ball logic to fully work and to have a true win state that would work. For the future we will start on projects much sooner to ensure that we would have a sufficient amount of time to get the project done. 

# Credits
The vga_driver file was obtained from Dr. Peter Jaimison and his project code files that he provided.

# AI-Usage
Disclosure that AI was used during the fixing of syntax errors and through sum bug fixing but all user functions as well as design decisions, such as block implementations in the vga_driver_memory, were through the lense of the Authors Mitchell and Marshall Gosney.
