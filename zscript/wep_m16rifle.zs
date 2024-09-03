// ------------------------------------------------------------
// M16
// ------------------------------------------------------------

class HDM16:HDWeapon{
	default{
		//$Category "Weapons/Hideous Destructor"
		//$Title "M16"
		//$Sprite "M16PA0"

		+hdweapon.fitsinbackpack
		obituary "%o got K.I.A.'d by %k's M16.";
		weapon.selectionorder 63;
		weapon.slotnumber 4;
		weapon.slotpriority 0.1;
		weapon.kickback 30;
		weapon.bobrangex 0.3;
		weapon.bobrangey 0.8;
		weapon.bobspeed 2.5;
		scale 0.65;
		inventory.pickupmessage "You got the M16!";
		hdweapon.barrelsize 24,0.5,1;
		hdweapon.refid "M16";
		tag "M16 combat rifle";
		inventory.icon "M16PA0";

		hdweapon.loadoutcodes "
			\cufiremode - 0-2, semi/burst/auto
			\cufireswitch - 0-4, default/semi/auto/full/all
			";
	}
	override bool AddSpareWeapon(actor newowner){return AddSpareWeaponRegular(newowner);}
	override hdweapon GetSpareWeapon(actor newowner,bool reverse,bool doselect){return GetSpareWeaponRegular(newowner,reverse,doselect);}

	override double gunmass(){
		return 6+((weaponstatus[SMGS_MAG]<0)?-0.5:(weaponstatus[SMGS_MAG]*0.05));
	}
	
	override double weaponbulk(){
		int mg=weaponstatus[SMGS_MAG];
		if(mg<0)return 100;
		else return (100+ENC_M16MAG_LOADED)+mg*ENC_556_LOADED;
	}
	
	override void failedpickupunload(){
		failedpickupunloadmag(SMGS_MAG,"HDM16Mag20");
	}
	
	override void DropOneAmmo(int amt){
		if(owner){
			amt=clamp(amt,1,10);
			if(owner.countinv("HD556Ammo"))owner.A_DropInventory("HD556Ammo",amt*20);
			else owner.A_DropInventory("HDM16Mag20",amt);
		}
	}
	
	override void postbeginplay(){
		super.postbeginplay();
		weaponspecial=1337;
		if(weaponstatus[SMGS_AUTO]>0){
		switch(weaponstatus[SMGS_SWITCHTYPE]){
		case 1:
			weaponstatus[SMGS_AUTO]=0;
			break;
		case 2:
			weaponstatus[SMGS_AUTO]=1;
			break;
		case 3:
			weaponstatus[SMGS_AUTO]=2;
			break;
		default:
			break;
		}}
	}
	
	override void ForceBasicAmmo(){
		owner.A_TakeInventory("HD556Ammo");
		ForceOneBasicAmmo("HDM16Mag20");
	}
	
	override string,double getpickupsprite(bool usespare){
		return "M16P"
			..((GetSpareWeaponValue(SMGS_MAG,usespare)<0)?"B":"A").."0",1.;
	}
	
	override void DrawHUDStuff(HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl){
		if(sb.hudlevel==1){
			int nextmagloaded=sb.GetNextLoadMag(hdmagammo(hpl.findinventory("HDM16Mag20")));
			if(nextmagloaded>=20){
				sb.drawimage("M16MA0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM);
			}else if(nextmagloaded<1){
				sb.drawimage("M16MB0",(-46,-3),sb.DI_SCREEN_CENTER_BOTTOM,alpha:nextmagloaded?0.6:1.);
			}else sb.drawbar(
				"M16MNORM","M16MGREY",
				nextmagloaded,20,
				(-46,-3),-1,
				sb.SHADER_VERT,sb.DI_SCREEN_CENTER_BOTTOM
			);
			sb.drawnum(hpl.countinv("HDM16Mag20"),-43,-8,sb.DI_SCREEN_CENTER_BOTTOM);
		}
		if(weaponstatus[SMGS_SWITCHTYPE]!=1)sb.drawwepcounter(hdw.weaponstatus[SMGS_AUTO],
			-22,-10,"RBRSA3A7","STBURAUT","STFULAUT"
		);
		sb.drawwepnum(hdw.weaponstatus[SMGS_MAG],20);
		if(hdw.weaponstatus[SMGS_CHAMBER]==2)sb.drawrect(-19,-11,3,1);
	}
	
	override string gethelptext(){
		return
		WEPHELP_FIRESHOOT
		..WEPHELP_RELOAD.."  Reload mag\n"
		..WEPHELP_USE.."+"..WEPHELP_RELOAD.."  Reload chamber\n"
		..WEPHELP_FIREMODE.."  Semi/Burst/Auto\n"
		..WEPHELP_MAGMANAGER
		..WEPHELP_UNLOADUNLOAD
		;
	}
	
	override void DrawSightPicture(
		HDStatusBar sb,HDWeapon hdw,HDPlayerPawn hpl,
		bool sightbob,vector2 bob,double fov,bool scopeview,actor hpc
	){
		vector2 bobb=bob*1.18;
		
			int cx,cy,cw,ch;
			[cx,cy,cw,ch]=screen.GetClipRect();
			sb.SetClipRect(
				-16+bob.x,-4+bob.y,32,16,
				sb.DI_SCREEN_CENTER
			);
			bobb.y=clamp(bobb.y,-19,19);
			sb.drawimage(
				"m16fsite",(0,-9)+bobb,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP
			);
			sb.SetClipRect(cx,cy,cw,ch);
			sb.drawimage(
				"m16bsite",(0,-9)+bob,sb.DI_SCREEN_CENTER|sb.DI_ITEM_TOP,
				alpha:0.9
			);
		
	}
	
	states{
	select0:
		M16G A 0;
		goto select0small;
	deselect0:
		M16G A 0;
		goto deselect0small;

	ready:
		M16G A 1{
			A_SetCrosshair(21);
			invoker.weaponstatus[SMGS_RATCHET]=0;
			A_WeaponReady(WRF_ALL);
		}
		goto readyend;
	user3:
		---- A 0 A_MagManager("HDM16Mag20");
		goto ready;
	altfire:
		goto chamber_manual;
	althold:
		goto nope;
	hold:
		#### A 0{
			if(
				invoker.weaponstatus[SMGS_CHAMBER]==2  //live round chambered
				&&(
					invoker.weaponstatus[SMGS_AUTO]==2  //full auto
					||(
						invoker.weaponstatus[SMGS_AUTO]==1  //burst
						&&invoker.weaponstatus[SMGS_RATCHET]<=2
					)
				)
			)setweaponstate("fire2");
		}goto nope;
	user2:
	firemode:
		---- A 1{
			int canaut=invoker.weaponstatus[SMGS_SWITCHTYPE];
			if(canaut==1){
				invoker.weaponstatus[SMGS_AUTO]=0;
				return;
			}
			int maxmode=(canaut>0)?(canaut-1):2;
			int aut=invoker.weaponstatus[SMGS_AUTO];
			if(aut>=maxmode)invoker.weaponstatus[SMGS_AUTO]=0;
			else if(aut<0)invoker.weaponstatus[SMGS_AUTO]=0;
			else if(canaut>0)invoker.weaponstatus[SMGS_AUTO]=maxmode;
			else invoker.weaponstatus[SMGS_AUTO]++;
		}goto nope;
	fire:
		#### A 0;
	fire2:
		#### A 1{
			if(invoker.weaponstatus[SMGS_CHAMBER]==2)A_GunFlash();
			else setweaponstate("chamber_manual");
		}
		#### A 1;
		#### A 0{
			if(invoker.weaponstatus[SMGS_CHAMBER]==1){
				A_EjectCasing("HDSpent556",
					frandom(-1,2),
					(frandom(0.2,0.3),-frandom(7,7.5),frandom(0,0.2)),
					(0,0,-2)
				);
				invoker.weaponstatus[SMGS_CHAMBER]=0;
			}
			if(invoker.weaponstatus[SMGS_MAG]>0){
				invoker.weaponstatus[SMGS_MAG]--;
				invoker.weaponstatus[SMGS_CHAMBER]=2;
			}
			if(invoker.weaponstatus[SMGS_AUTO]==2)A_SetTics(1);
		}
		#### A 0 A_ReFire();
		goto ready;
	flash:
		#### A 0{
			let bbb=HDBulletActor.FireBullet(self,"HDB_556",speedfactor:frandom(0.99,1.01));
			if(
				frandom(16,ceilingz-floorz)<bbb.speed*0.1
			)A_AlertMonsters();

			A_ZoomRecoil(0.995);
			A_StartSound("weapons/m16",CHAN_WEAPON);
			invoker.weaponstatus[SMGS_RATCHET]++;
			invoker.weaponstatus[SMGS_CHAMBER]=1;
		}
		M16F B 0;
		M16F B 0 A_Jump(128,2);
	    M16F A 0;
		#### # 1 bright{
			HDFlashAlpha(-200);
			A_Light1();
		}
		TNT1 A 0 A_MuzzleClimb(-frandom(0.3, 0.5),
		                       -frandom(0.5, 1.0),
                               -frandom(0.8, 1.5),
		                       -frandom(0.4, 0.9),
		                       -frandom(0.2, 0.4)
		                       );
		goto lightdone;


	unloadchamber:
		#### A 4 A_JumpIf(invoker.weaponstatus[SMGS_CHAMBER]<1,"nope");
		#### A 1 offset(0,34);
		#### A 1 offset(5,38);
		#### A 2 offset(10,42);
		#### A 4 offset(20,46){
		    A_StartSound("weapons/smgmagclick",8);
			class<actor>which=invoker.weaponstatus[SMGS_CHAMBER]>1?"HDLoose556":"HDSpent556";
			invoker.weaponstatus[SMGS_CHAMBER]=0;
			A_SpawnItemEx(which,
				cos(pitch)*10,0,height*0.82-sin(pitch)*10,
				vel.x,vel.y,vel.z,
				0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPITCH
			);
		}
		#### A 2 offset(10,42);
		#### A 1 offset(5,38);
		#### A 1 offset(0,34);
		goto readyend;
	loadchamber:
		---- A 0 A_JumpIf(invoker.weaponstatus[SMGS_CHAMBER]>0,"nope");
		---- A 0 A_JumpIf(!countinv("HD556Ammo"),"nope");
		---- A 1 offset(0,34) A_StartSound("weapons/pocket",9);
		---- A 1 offset(2,36);
		---- A 1 offset(2,44);
		#### A 1 offset(5,58);
		#### A 2 offset(7,70);
		#### A 6 offset(8,80);
		#### A 10 offset(8,87){
			if(countinv("HD556Ammo")){
				A_TakeInventory("HD556Ammo",1,TIF_NOTAKEINFINITE);
				invoker.weaponstatus[SMGS_CHAMBER]=2;
				A_StartSound("weapons/smgchamber",8);
			}else A_SetTics(4);
		}
		#### A 3 offset(9,76);
		---- A 2 offset(5,70);
		---- A 1 offset(5,64);
		---- A 1 offset(5,52);
		---- A 1 offset(5,42);
		---- A 1 offset(2,36);
		---- A 2 offset(0,34);
		goto nope;
	user4:
	unload:
		#### A 0{
			invoker.weaponstatus[0]|=SMGF_JUSTUNLOAD;
			if(
				invoker.weaponstatus[SMGS_MAG]>=0
			)setweaponstate("unmag");
			else if(invoker.weaponstatus[SMGS_CHAMBER]>0)setweaponstate("unloadchamber");
		}goto nope;
	reload:
		#### A 0{
			invoker.weaponstatus[0]&=~SMGF_JUSTUNLOAD;
			bool nomags=HDMagAmmo.NothingLoaded(self,"HDM16Mag20");
			if(invoker.weaponstatus[SMGS_MAG]>=20)setweaponstate("nope");
			else if(
				invoker.weaponstatus[SMGS_MAG]<1
				&&(
					pressinguse()
					||nomags
				)
			){
				if(
					countinv("HD556Ammo")
				)setweaponstate("loadchamber");
				else setweaponstate("nope");
			}else if(nomags)setweaponstate("nope");
		}goto unmag;
	unmag:
		#### A 1 offset(0,34) A_SetCrosshair(21);
		#### A 1 offset(5,38);
		#### A 1 offset(10,42);
		#### A 2 offset(20,46) A_StartSound("weapons/smgmagclick",8);
		#### A 4 offset(30,52){
			A_MuzzleClimb(0.3,0.4);
			A_StartSound("weapons/smgmagmove",8,CHANF_OVERLAP);
		}
		#### A 0{
			int magamt=invoker.weaponstatus[SMGS_MAG];
			if(magamt<0){
				setweaponstate("magout");
				return;
			}
			invoker.weaponstatus[SMGS_MAG]=-1;
			if(
				(!PressingUnload()&&!PressingReload())
				||A_JumpIfInventory("HDM16Mag20",0,"null")
			){
				HDMagAmmo.SpawnMag(self,"HDM16Mag20",magamt);
				setweaponstate("magout");
			}else{
				HDMagAmmo.GiveMag(self,"HDM16Mag20",magamt);
				A_StartSound("weapons/pocket",9);
				setweaponstate("pocketmag");
			}
		}
	pocketmag:
		#### AA 7 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
	magout:
		#### A 0{
			if(invoker.weaponstatus[0]&SMGF_JUSTUNLOAD)setweaponstate("reloadend");
			else setweaponstate("loadmag");
		}

	loadmag:
		#### A 0 A_StartSound("weapons/pocket",9);
		#### A 6 offset(34,54) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### A 7 offset(34,52) A_MuzzleClimb(frandom(0.2,-0.8),frandom(-0.2,0.4));
		#### A 10 offset(32,50);
		#### A 3 offset(32,49){
			let mmm=hdmagammo(findinventory("HDM16Mag20"));
			if(mmm){
				invoker.weaponstatus[SMGS_MAG]=mmm.TakeMag(true);
				A_StartSound("weapons/smgmagclick",8,CHANF_OVERLAP);
			}
			if(
				invoker.weaponstatus[SMGS_MAG]<1
				||invoker.weaponstatus[SMGS_CHAMBER]>0
			)setweaponstate("reloadend");
		}
		goto reloadend;

	reloadend:
		#### A 3 offset(30,52);
		#### A 2 offset(20,46);
		#### A 1 offset(10,42);
		#### A 1 offset(5,38);
		#### A 1 offset(0,34);
		goto chamber_manual;

	chamber_manual:
		#### A 0 A_JumpIf(
			invoker.weaponstatus[SMGS_MAG]<1
			||invoker.weaponstatus[SMGS_CHAMBER]==2
		,"nope");
		#### A 2 offset(3,32){
			A_WeaponBusy();
			invoker.weaponstatus[SMGS_MAG]--;
			invoker.weaponstatus[SMGS_CHAMBER]=2;
		}
		#### A 3 offset(5,35) A_StartSound("weapons/smgchamber",8,CHANF_OVERLAP);
		#### A 1 offset(3,32);
		#### A 1 offset(2,31);
		goto nope;


	spawn:
		TNT1 A 1;
		M16P A -1{
			if(invoker.weaponstatus[SMGS_MAG]<0)frame=1;
		}
		stop;
	}
	override void initializewepstats(bool idfa){
		weaponstatus[SMGS_MAG]=20;
		weaponstatus[SMGS_CHAMBER]=2;
	}
	override void loadoutconfigure(string input){
		int firemode=getloadoutvar(input,"firemode",1);
		if(firemode>=0)weaponstatus[SMGS_AUTO]=clamp(firemode,0,2);

		int fireswitch=getloadoutvar(input,"fireswitch",1);
		if(fireswitch>3)weaponstatus[SMGS_SWITCHTYPE]=0;
		else if(fireswitch>0)weaponstatus[SMGS_SWITCHTYPE]=clamp(fireswitch,0,3);
	}
}

class HDM16Random:IdleDummy{
	states{
	spawn:
		TNT1 A 0 nodelay{
			let lll=HDM16(spawn("HDM16",pos,ALLOW_REPLACE));
			if(!lll)return;
			lll.special=special;
			lll.vel=vel;
			for(int i=0;i<5;i++)lll.args[i]=args[i];
			if(!random(0,2))lll.weaponstatus[SMGS_SWITCHTYPE]=random(0,3);
            Spawn("HDM16Mag20",pos,ALLOW_REPLACE);	
            Spawn("HDM16Mag20",pos,ALLOW_REPLACE);	
	
		}stop;
	}
}

