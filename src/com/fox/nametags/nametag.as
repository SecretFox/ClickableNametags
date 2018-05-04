import com.GameInterface.DistributedValue;
import com.GameInterface.DistributedValueBase;
import com.GameInterface.Game.TargetingInterface;
import com.Utils.ID32;
import mx.utils.Delegate;
class com.fox.nametags.nametag{
	
	private var NametagClick:DistributedValue;
	private var NametagController:MovieClip;
	
	public static function main(swfRoot:MovieClip):Void{
		var s_app = new nametag(swfRoot);
		swfRoot.onLoad = function () {s_app.Hook()};
		swfRoot.onUnload = function () {s_app.Exit()};
	}
	public function nametag() { }
	public function Hook(){
		NametagController = _root.nametagcontroller;
		if (!NametagController.CreateNametag){
			setTimeout(Delegate.create(this, Hook), 100);
			return
		}
		NametagClick = DistributedValue.Create("NametagClicked");
		//this should take care of all the new tags
		NametagClick.SignalChanged.Connect(ChangeTarget, this);
		if (!NametagController._CreateNametag){
			NametagController._CreateNametag = NametagController.CreateNametag;
			NametagController.CreateNametag = function (characterID) {
				var tag = _root.nametagcontroller._CreateNametag(characterID);
				tag.onPress = Delegate.create(this, function () {
					DistributedValueBase.SetDValue("NametagClicked", characterID);
				});
				return tag
			}
		}
		//hook the ones we missed
		for (var i in NametagController.m_NametagArray){
			var tag = NametagController.m_NametagArray[i];
			HookTag(tag);
		}
	}
	private function HookTag(tag){
		tag.onPress = Delegate.create(this, function () {
			DistributedValueBase.SetDValue("NametagClicked", tag.m_DynelID);
		});
	}
	public function Exit(){
		NametagClick.SignalChanged.Disconnect(ChangeTarget, this);
	}
	private function ChangeTarget(dv:DistributedValue){
		var ID:ID32 = dv.GetValue();
		if (ID){
			if(ID.IsPlayer()){
				TargetingInterface.SetTarget(ID);
			}
			dv.SetValue(false);
		}
	}
}