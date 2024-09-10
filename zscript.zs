version "4.8"

#include "zscript/ammo_556.zs"
#include "zscript/wep_m16rifle.zs"

class M16_Spawner : EventHandler{

override void CheckReplacement( ReplaceEvent M16 ){

 switch ( M16.Replacee.GetClassName() ) {

    //ZM66 spawns
    case 'ClipBoxPickup1'   :   if(M16_ZM66SpawnBias<0)break;
                                if(!random(0,M16_ZM66SpawnBias))M16.Replacement = "HDM16Random";
                                break;
    
    //Chaingun spawns
    case 'Chaingun'     :   if(M16_ChaingunSpawnBias<0)break;
                            if(!random(0,M16_ChaingunSpawnBias))M16.Replacement = "HDM16Random";
                            break;
    
    //Clip spawns
    case 'Clip'     :   if(M16_MagSpawnBias<0)break;
                        if(!random(0,M16_MagSpawnBias))M16.Replacement = "HDM16Mag20";
                        break;
    //Ammobox spawns                            
    case 'Clipbox'  :   if(M16_AmmoSpawnBias<0)break;
                        if(!random(0,M16_AmmoSpawnBias))M16.Replacement = "HD556BoxPickup";
                        break;
    
    }

    M16.IsFinal = false;

  }

}
