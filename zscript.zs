version "4.8"

#include "zscript/ammo_556.zs"
#include "zscript/wep_m16rifle.zs"


class M16_Spawner : EventHandler{

override void CheckReplacement( ReplaceEvent M16 ){

 switch ( M16.Replacee.GetClassName() ) {

    case 'ClipBoxPickup1'   :   if(M16_ReplaceZM66Spawns)M16.Replacement = "HDM16Random";
        break;
    
    case 'Chaingun'   :   if(M16_ReplaceChaingunSpawns)M16.Replacement = "HDM16Random";
        break;
    
    case 'HD4mMag'   :   if(M16_Replace4mmMagSpawns)M16.Replacement = "HDM16Mag20";
        break;
    
    case 'Clip'   :   if(M16_Allow556AmmoSpawns){
                        if(!random(0,9))M16.Replacement = "HD556BoxPickup";}
     
    case 'Clipbox'   :   if(M16_Allow556AmmoSpawns){
                        if(!random(0,7))M16.Replacement = "HD556BoxPickup";}
     
        break;
    
    }

    M16.IsFinal = false;

  }

}
