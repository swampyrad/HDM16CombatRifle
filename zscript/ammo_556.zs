// ------------------------------------------------------------
// 5.56x45 NATO Ammo
// ------------------------------------------------------------
const ENC_M16MAG=11;
const ENC_M16MAG_EMPTY=ENC_M16MAG*0.3;
const ENC_556_LOADED=(ENC_M16MAG*0.7)/20.;
const ENC_556=ENC_556_LOADED*1.35;
const ENC_M16MAG_LOADED=ENC_M16MAG_EMPTY*0.5; 

class HDB_556:HDBulletActor{
	default{
		pushfactor 0.3;
		mass 40;
		speed HDCONST_MPSTODUPT*960;
		accuracy 600;
		stamina 556;
		woundhealth 10;
		hdbulletactor.hardness 3;
		hdbulletactor.distantsound "world/riflefar";
	}
}

class HD556Ammo:HDRoundAmmo{
	default{
		+inventory.ignoreskill
		+cannotpush
		+forcexybillboard
		+rollsprite +rollcenter
		+hdpickup.multipickup
		xscale 0.6;
		yscale 0.5;
		inventory.pickupmessage "Picked up a 5.56 round.";
		hdpickup.refid "556";
		tag "5.56 NATO ammo";
		hdpickup.bulk ENC_556;
		inventory.icon "T556A0";
	}
	override void SplitPickup(){
		SplitPickupBoxableRound(10,50,"HD556BoxPickup","T556A0","BRS5A0");
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDM16");
	}
	states{
	spawn:
		BRS5 A -1;
		T556 A -1;
	}
}

class HDM16Mag20:HDMagAmmo{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "M16 Magazine"
		//$Sprite "M16MA0"
        scale 0.35;
		hdmagammo.maxperunit 20;
		hdmagammo.roundtype "HD556Ammo";
		hdmagammo.roundbulk ENC_556_LOADED;
		hdmagammo.magbulk ENC_M16MAG_EMPTY;
		tag "M16 20-round magazine";
		inventory.pickupmessage "Picked up an M16 20-round magazine.";
		hdpickup.refid "520";
	}
	override string,string,name,double getmagsprite(int thismagamt){
		string magsprite=(thismagamt>0)?"M16MNORM":"M16MEMPTY";
		return magsprite,"BRS5A3A7","HD556Ammo",0.6;
	}
	override void GetItemsThatUseThis(){
		itemsthatusethis.push("HDM16");
	}
	states{
	spawn:
		M16M A -1;
		stop;
	spawnempty:
		M16M B -1 A_SpawnEmpty();
		stop;
	}
}


class HDSpent556:HDDebris{
	default{
		bouncesound "misc/casing_556";scale 0.6;
        bouncefactor 0.4; maxstepheight 0.6;
        bouncetype "doom";
	}
	states{
	spawn:
		BRS5 A 2{
			if(bseesdaggers)angle-=45;else angle+=45;
			if(pos.z-floorz<2&&abs(vel.z)<2.)setstatelabel("death");
		}wait;
	death:
		BRS5 A -1{
			if(hdmath.deathmatchclutter())A_SetTics(140);
			bmissile=false;
			vel.xy+=(pos.xy-prev.xy)*max(abs(vel.z),abs(prev.z-pos.z),1.);
			if(vel.xy==(0,0)){
				double aaa=angle-90;
				vel.x+=cos(aaa);
				vel.y+=sin(aaa);
			}else{
				A_FaceMovementDirection();
				angle+=90;
			}
		//	let gdb=getdefaultbytype(pickuptype);
		//	A_SetSize(gdb.radius,gdb.height);
			return;
		}stop;
	}
}
class HDLoose556:HDSpent556{
	default{
		bouncefactor 0.5;
	}
	states{
	death:
		TNT1 A 1{
			actor a=spawn("HD556Ammo",self.pos,ALLOW_REPLACE);
			a.roll=self.roll;a.vel=self.vel;
		}stop;
	}
}

class HDM16EmptyMag:IdleDummy{
	override void postbeginplay(){
		super.postbeginplay();
		HDMagAmmo.SpawnMag(self,"HDM16Mag20",0);
		destroy();
	}
}

class HD556BoxPickup:HDUPK{
	default{
		//$Category "Ammo/Hideous Destructor/"
		//$Title "Box of 5.56 NATO Ammo"
		//$Sprite "556BA0"

		scale 0.5;
		hdupk.amount 100;
		hdupk.pickupsound "weapons/pocket";
		hdupk.pickupmessage "Picked up some 5.56 ammo.";
		hdupk.pickuptype "HD556Ammo";
	}
	states{
	spawn:
		556B A -1;
	}
}

