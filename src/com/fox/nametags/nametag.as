import com.GameInterface.DistributedValue;
import com.GameInterface.Game.Character;
import com.GameInterface.Game.Dynel;
import com.GameInterface.Game.TargetingInterface;
import com.Utils.ID32;
import flash.geom.Point;
import mx.utils.Delegate;

class com.fox.nametags.nametag
{
	static var AllowNPC:DistributedValue;
	static var AllowRight:DistributedValue;

	public static function main(swfRoot:MovieClip):Void
	{
		var s_app = new nametag(swfRoot);
		swfRoot.onLoad = function () {s_app.Hook()};
	}
	public function nametag()
	{
		AllowNPC = DistributedValue.Create("ClickableNametags_AllowNPC");
		AllowRight = DistributedValue.Create("ClickableNametags_AllowRightClick");
	}

	static function NametagClicked()
	{
		var button:Number = Mouse.getButtonsState(0);
		if ( button == 2 && !AllowRight.GetValue())
		{
			return;
		}
		var pos:Point = Mouse.getPosition();
		var target;
		var closest:Number = 10000;
		
		var clientID:ID32 = Character.GetClientCharacter().GetID();
		for (var i in _root.nametagcontroller.m_NametagArray)
		{
			var nametag = _root.nametagcontroller.m_NametagArray[i];
			var dynel:Dynel = nametag["m_Dynel"];
			var id:ID32 = nametag.GetDynelID();
			if ( nametag.hitTest(pos.x, pos.y))
			{
				if  (id.Equal(clientID) || // Player
					(( button == 2 || !AllowNPC.GetValue()) && !id.IsPlayer()) || // Right click on NPC, or NPC targeting disabled
					dynel.IsEnemy()  // Enemy
				) continue;
				
				var distance;
				if (nametag["m_Name"]._alpha != 0)
				{
					distance =
						Math.abs(pos.x - (nametag._x + nametag["m_Name"].textWidth * nametag._xscale / 200)) +
						Math.abs(pos.y - (nametag._y + (nametag["m_Name"].textHeight+3) * nametag._yscale / 200));
				}
				else
				{
					var bounds = nametag.getBounds(_root);
					bounds.xMax = bounds.xMin + (bounds.xMax - bounds.xMin) * 0.65; // invisible elements
					distance =
						Math.abs(pos.x - (bounds.xMin + (bounds.xMax - bounds.xMin) / 2)) +
						Math.abs(pos.y - (bounds.yMin + (bounds.yMax - bounds.yMin) / 2));
				}
				if (distance < closest)
				{
					target = nametag;
					closest = distance;
				}
			}
		}
		if ( target )
		{
			if (button == 1) TargetingInterface.SetTarget(target.GetDynelID());
			else com.Utils.GlobalSignal.SignalShowFriendlyMenu.Emit( target.GetDynelID(), target["m_Name"].text, true);
		}
	}

	public function Hook()
	{
		var NametagController = _root.nametagcontroller;
		if (!NametagController.CreateNametag)
		{
			setTimeout(Delegate.create(this, Hook), 100);
			return
		}
		// This should take care of all the new tags
		if (!NametagController.CreateNametag.base)
		{
			var f = function (characterID)
			{
				var tag = arguments.callee.base.apply(this, arguments);
				tag.onPress = nametag.NametagClicked;
				tag.onPressAux = nametag.NametagClicked;
				return tag
			}
			f.base = NametagController.CreateNametag;
			NametagController.CreateNametag = f;
		}
		// Hook already created
		for (var i in NametagController.m_NametagArray)
		{
			var tag = NametagController.m_NametagArray[i];
			tag.onPress = NametagClicked;
			tag.onPressAux = NametagClicked;
		}
	}

}