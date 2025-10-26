extends Node

#if you're getting a lot of warnings about signals being decleared but never explisitly used in the class, don't worry about it
#it's just a quirk of this implementation of the observer pattern.
#you can turn off the warning flag in editor settings. 


#signal PopupMessage(textToSay : String, pos : Vector2, move_to : Vector2, textColour : Color)

signal register_human(human : Area2D)

signal human_infected(human: Area2D)
#signal main_target_infected(level: LevelInfo)
signal cactchiness_gone()
