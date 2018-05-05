import com.GameInterface.Game.TargetingInterface;
import mx.utils.Delegate;
class com.fox.nametags.nametag{
	private var NametagController:MovieClip;
	
	public static function main(swfRoot:MovieClip):Void{
		var s_app = new nametag(swfRoot);
		swfRoot.onLoad = function () {s_app.Hook()};
	}
	public function nametag() { }
	public function Hook(){
		NametagController = _root.nametagcontroller;
		if (!NametagController.CreateNametag){
			setTimeout(Delegate.create(this, Hook), 100);
			return
		}
		//this should take care of all the new tags
		if (!NametagController._CreateNametag){
			NametagController._CreateNametag = NametagController.CreateNametag;
			NametagController.CreateNametag = function (characterID) {
				var tag = _root.nametagcontroller._CreateNametag(characterID);
				tag.onPress = Delegate.create(this, function () {
					if(characterID.IsPlayer()){
						TargetingInterface.SetTarget(characterID);
					}
				});
				// Right-click. this function is not included in the left-click release.
				tag.onPressAux = Delegate.create(this, function () {
					//this should work with SWLRP
					com.Utils.GlobalSignal.SignalShowFriendlyMenu.Emit( characterID, tag.m_Dynel.GetName(), true);
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
			if(tag.m_DynelID.IsPlayer()){
				TargetingInterface.SetTarget(tag.m_DynelID);
			}
		});
		// Right-click. this function is not included in the left-click release.
		tag.onPressAux = Delegate.create(this, function () {
			//this should work with SWLRP
			com.Utils.GlobalSignal.SignalShowFriendlyMenu.Emit( tag.m_DynelID, tag.m_Dynel.GetName(), true);
		});
	}
}