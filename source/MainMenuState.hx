package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.6.2';
	public static var curSelected:Int = 2;

	var menuItems:FlxTypedGroup<FlxSprite>;

	var optionShit:Array<String> = ['Options', 'Freeplay', 'Storymode', 'Nightmare', 'Credits'];

	var debugKeys:Array<FlxKey>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		// Menu Backgrounds
		for (i in 0...optionShit.length)
		{
			var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/bgs/' + optionShit[i] + 'Background'));
			menuBG.setGraphicSize(FlxG.width, FlxG.height);
			menuBG.updateHitbox();
			menuBG.screenCenter(X);
			menuBG.antialiasing = ClientPrefs.globalAntialiasing;
			menuBG.ID = i;
			add(menuBG);
		}

		// Menu Characters
		for (i in 0...optionShit.length)
		{
			var menuChar:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/chars/' + optionShit[i] + 'Character'));
			menuChar.setGraphicSize(FlxG.width, FlxG.height);
			menuChar.updateHitbox();
			menuChar.screenCenter(X);
			menuChar.antialiasing = ClientPrefs.globalAntialiasing;
			menuChar.ID = i;
			add(menuChar);
		}

		// The dividers :)
		var dividers:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/dividers'));
		dividers.setGraphicSize(FlxG.width, FlxG.height);
		dividers.updateHitbox();
		dividers.screenCenter(X);
		dividers.antialiasing = ClientPrefs.globalAntialiasing;
		add(dividers);

		// Menu Buttons
		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite().loadGraphic(Paths.image('mainmenu/text/' + optionShit[i] + 'Text'));
			menuItem.setGraphicSize(FlxG.width, FlxG.height);
			menuItem.updateHitbox();
			menuItem.screenCenter(X);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.ID = i;
			menuItems.add(menuItem);
		}

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
		{
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if (!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2]))
			{ // It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if (FreeplayState.vocals != null)
				FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));

				menuItems.forEach(function(spr:FlxSprite)
				{
					if (curSelected != spr.ID)
					{
						FlxTween.tween(spr, {alpha: 0}, 0.4, {
							ease: FlxEase.quadOut,
							onComplete: function(twn:FlxTween):Void
							{
								spr.kill();
							}
						});
					}
					else
					{
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker):Void
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'Options':
									LoadingState.loadAndSwitchState(new options.OptionsState());
								case 'Freeplay':
									MusicBeatState.switchState(new FreeplayState());
								case 'Storymode':
									MusicBeatState.switchState(new StoryMenuState());
								case 'Nightmare':
									MusicBeatState.switchState(new NightmareState());
								case 'Credits':
									MusicBeatState.switchState(new CreditsState());
								#if MODS_ALLOWED
								case 'mods':
									MusicBeatState.switchState(new ModsMenuState());
								#end
								#if ACHIEVEMENTS_ALLOWED
								case 'awards':
									MusicBeatState.switchState(new AchievementsMenuState());
								#end
							}
						});
					}
				});
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new editors.MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite):Void
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0):Void
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite):Void
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if (menuItems.length > 4)
				{
					add = menuItems.length * 8;
				}
				spr.centerOffsets();
			}
		});
	}
}
