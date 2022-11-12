package;

import flixel.FlxG;
import flixel.FlxSprite;

class NightmareState extends MusicBeatState
{
	override function create()
	{
		var spam:FlxSprite = new FlxSprite().loadGraphic(Paths.image('placeholder'));
		spam.screenCenter();
		add(spam);
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (transitioning)
		{
			super.update(elapsed);
			return;
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			MusicBeatState.switchState(new MainMenuState());
			transitioning = true;
		}
	}
}
