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
	}
	public function nametag() { }
	public function Hook(){
		NametagClick = DistributedValue.Create("NametagClicked");
		NametagClick.SignalChanged.Connect(ChangeTarget, this);
		if (!_root.nametagcontroller.CreateNametag){
			setTimeout(Delegate.create(this, Hook), 100);
			return
		}
		NametagController = _root.nametagcontroller;
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
	}
	private function ChangeTarget(dv:DistributedValue){
		var PlayerdID:ID32 = dv.GetValue();
		if (PlayerdID){
			if(PlayerdID.IsPlayer()){
				TargetingInterface.SetTarget(PlayerdID);
			}
			dv.SetValue(false);
		}
	}
}