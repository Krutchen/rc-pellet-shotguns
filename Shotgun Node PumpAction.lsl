//HOW TO BALANCE SHOTGUN - THIS IS A GUIDELINE NOT A RULEBOOK, DON'T GO WAY OFF THIS AND MAKE YOUR SHOTGUN LAME THOUGH
//Reload time = 4.8 * .5 = 2.4  // Get your reload time, half it if interuptable (pump action) because that's a huge boon.
//Total dump time = Magdump time + Reload time = 4.56 + 2.4 = 6.96 - This shotgun has a .57 delay between each shot + growing spread
//Dump per min = 60/Total dump time =  60/6.96 = 8.62 can magdump 8.62 times in a minute
//RPM = Number of shots * Dump per min = 8 * 8.62 = 68.96 which means this is 68.96 RPM
//Pellet Count = 750 (Ballpark average rifle rpm) / RPM rounded to nearest number - 750/69 = 10.8, round down to 10
//100-RPM = gives you your max kill range, rounded down to nearest 5. - 100-68.96 gives us 31.04 rounded to 30. Falloff range should be 150% of max kill range
//Keep your basic buckshot to 1 AT on LBA Light only, make other round types for extra effects that trade effectiveness vs infantry and etc
vector pos;
rotation rot;
vector fpos;
rotation frot;
float max=30;//Max range at what 
float end=75;//This should be 
float falloff=2.2;//Your value for per meter falloff should be 100/(end-max), ie 100/45=2.2222222
integer mode=0;
integer hits;
integer at=1;
vector findrez(vector rez)
{
    integer pf=llGetParcelFlags(rez)&PARCEL_FLAG_ALLOW_CREATE_OBJECTS;
    if(pf)
    {
        integer prims=llGetParcelPrimCount(rez,0,0);
        integer max=llGetParcelMaxPrims(rez,0);
        if(max-prims>1)jump out;
    }
    list pk;//Parcel IDs
    float rad=0;
    float range=0;
    @loop;
    key id=llList2Key(llGetParcelDetails(rez,[PARCEL_DETAILS_ID]),0);
    if(llListFindList(pk,[id])==-1)
    {
        pf=llGetParcelFlags(rez)&PARCEL_FLAG_ALLOW_CREATE_OBJECTS;
        if(pf)
        {
            integer prims=llGetParcelPrimCount(rez,0,0);
            integer max=llGetParcelMaxPrims(rez,0);
            if(max-prims>1)jump out;
        }
        else pk+=id;
    }
    if(range)rad+=45;
    else range=1;
    if(rad==360)
    {
        rad=0;
        range+=1;
    }
    rez=llGetPos()+<range,0,0>*llEuler2Rot(<0,0,rad>*DEG_TO_RAD);
    if(rez.x>255.9)rez.x=255.9;
    if(rez.x<.1)rez.x=.1;
    if(rez.y>255.9)rez.y=255.9;
    if(rez.y<.1)rez.y=.1;
    if(range<15)jump loop;
    @out;
    return rez;
}
vector clamp(vector start, vector dir){
    dir += <1E-6,1E-6,1E-6>;
    vector invDir = <1./dir.x, 1./dir.y, 1./dir.z>;
    vector max = <255.,255.,4095.> - start;
    vector X;
    
    if(dir.x < 0.){
        X = start - (start.x * invDir.x) * dir;
        if(X.y > 0. && X.y <= 256. && X.z <= 4096. && X.z >= 0.) return X;
    } else{
        X = start + (max.x * invDir.x) * dir;
        if(X.y > 0. && X.y <= 256. && X.z <= 4096. && X.z >= 0.) return X;
    }
    
    if(dir.y < 0.){
        X = start - (start.y * invDir.y) * dir;
        if(X.x > 0. && X.x <= 256. && X.z <= 4096. && X.z >= 0.) return X;
    } else{
        X = start + (max.y * invDir.y) * dir;
        if(X.x > 0. && X.x <= 256. && X.z <= 4096. && X.z >= 0.) return X;
    }
    
    if(dir.z < 0.){
        X = start - (start.z * invDir.z) * dir;
        if(X.x >= 0. && X.x <= 256. && X.y >= 0. && X.y <= 256.) return X;
    }
    return start + (max.z * invDir.z) * dir;
}
integer bound(vector input)
{
    integer oob;
    if(input.x>=256)oob=1;
    if(input.x<=0)oob=1;
    if(input.y>=256)oob=1;
    if(input.y<=0)oob=1;
    if(input.z>=4056)oob=1;
    if(input.z<=0)oob=1;
    return oob;
}
string EncodePosToBase64(vector pos)
{
    string x = llGetSubString(llIntegerToBase64(llRound(pos.x * 10)), 3, 5);
    string y = llGetSubString(llIntegerToBase64(llRound(pos.y * 10)), 3, 5);
    string z = llGetSubString(llIntegerToBase64(llRound(pos.z * 10)), 2, 5);
    return x + y + z;
}
vector DecodeBase64ToPos(string base64)
{
    float x = (float)llBase64ToInteger("AAA" + llGetSubString(base64, 0, 2)) / 10;
    float y = (float)llBase64ToInteger("AAA" + llGetSubString(base64, 3, 5)) / 10;
    float z = (float)llBase64ToInteger("AA" + llGetSubString(base64, 6, 9)) / 10;
    return <x, y, z>;
}
list results;
default
{
    state_entry()
    {
        llRequestPermissions(llGetOwner(),0x4|0x400);
    }
    run_time_permissions(integer p) 
    {
        llTakeControls(0x40000000,1,1); 
    }
    attach(key id)
    {
        if(id!=NULL_KEY)llResetScript();
    }
    changed(integer c)
    {   
        if(c&CHANGED_COLOR)
        {
            vector color=llGetColor(1);
            if(color.x!=1)
            {
                llSetTimerEvent(0);
                fpos=llGetCameraPos();
                frot=llGetCameraRot();
                if(color.x==.1)
                {
                    float calc=(float)llGetObjectDesc();
                    float hc=calc*.5;
                    mode=0;
                    results=[];
                    list hits;
                    integer pellets=10;
                    while(pellets--)
                    {
                        rotation spr=(llEuler2Rot(<0,(llFrand(calc)-hc)*.75,llFrand(calc)-hc>))*frot;
                        vector start=fpos;
                        integer dmg;
                        @phcheck;
                        vector en=start+<end,0,0>*spr;
                        if(bound(en))en=clamp(start,<1,0,0>*spr);
                        list rc=llCastRay(start,en,[RC_MAX_HITS,2,RC_DATA_FLAGS,2]);
                        if(llList2Key(rc,0)==llGetOwner())rc=llListReplaceList(rc,[],0,1);
//Because we're starting at camera pos you can technically hit yourself if you're moving too fast ahead or the start position is grabbed the frame before the raycast fires, this prevents you from hitting yourself.
                        key tar=llList2Key(rc,0);
                        vector poshit=llList2Vector(rc,1);
                        if(poshit==ZERO_VECTOR)poshit=en;
                        if(tar!=NULL_KEY)
                        {
                            list data=llGetObjectDetails(tar,[OBJECT_DESC,OBJECT_PHANTOM,OBJECT_RUNNING_SCRIPT_COUNT]);
                            integer phantom=llList2Integer(data,1);
                            if(phantom)
                            {
                                start=poshit+<.05,0,0>*spr;
                                jump phcheck;
//Phantom check loop defeats raycast blockers because every now and then someone pulls out something stupid like that, and sometimes people do it unintentionally on their builds
                            }
                            else
                            {
                                float dist=llVecDist(fpos,poshit);
                                if(dist<=max)dmg=100;
                                else dmg=100-llRound((dist-max)*falloff);
                                if(dmg<0)dmg=0;
                                if(llGetAgentSize(tar)==ZERO_VECTOR)
                                {
                                    integer atdmg=at;
                                    if(llList2Integer(data,2)&&dist<max*2)
                                    {
                                        string desc=llList2String(data,0);
                                        if(desc!=""&&(llGetSubString(desc,0,5)=="LBA.v."&&llGetListLength(llCSV2List(desc))<3||llGetSubString(desc,0,6)=="LBA.v.L"))
                                        {
                                            dmg=atdmg;
                                            integer hex=(integer)("0x" + llGetSubString(llMD5String((string)tar,0), 0, 3));
                                            llRegionSayTo(tar,hex,(string)tar+","+(string)atdmg);
//We are doing a damage message per pellet so the recieving end can get an accurate read on how many hits they recieved, and it won't avoid mitigation on say directional armour.
                                            tar=llKey2Name(tar);
                                        }
                                        else tar="";
                                    }
                                    else tar="";
                                }
                                if(tar!=""&&dmg>0)
                                {
                                    integer find=llListFindList(results,[(string)tar]);//Am I already present on the result list?
                                    if(find==-1)results+=[(string)tar,dmg,1,llDeleteSubString((string)dist, -4, -1)];
                                    else results=llListReplaceList(results,[llList2Integer(results,find+1)+dmg,llList2Integer(results,find+2)+1],find+1,find+2);
//If we already have an entry add damage, we already sent our AT damage for objects, but we want to only use one kill prim for avatars.
                                }
                            }
                        }
                        string val=EncodePosToBase64(poshit);
                        hits+=val;
                    }
                    llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_TEXT,llDumpList2String(hits,"|"),<1,1,1>,0]);//Sets prim text to transfer the data to tracers
                    llRezAtRoot("Shotgun Tracer",fpos+<2,0,0>*frot,ZERO_VECTOR,frot,1);//Rezzes tracers which then read the invisible float text now above your shotgun
                    integer len=llGetListLength(results)-1;//List for processing damage + reporting hits
                    while(len>0)
                    {
                        key tar=llList2Key(results,len-3);
                        integer dmg=llList2Integer(results,len-2);
                        integer hits=llList2Integer(results,len-1);
                        string dist=llList2String(results,len);
                        if(llGetAgentSize(tar))
                        {
                            if(dmg>100)dmg=100;
                            integer pass=((integer)("0x" + llGetSubString(tar, 0, 3)) << 16) | dmg;
                            llRezAtRoot("[Heretech] Shotgun Pellets",findrez(llGetPos()),ZERO_VECTOR,ZERO_ROTATION,pass);
                            llOwnerSay("/me :: Hit secondlife:///app/agent/"+(string)tar+"/about "+(string)hits+" times for "+(string)dmg+" dmg @ "+dist+"m");
                        }
                        else llOwnerSay("/me :: Hit "+(string)tar+" "+(string)hits+" times for "+(string)dmg+" AT @ "+dist+"m");
                        len-=4;//Jump back by 4 values for the length of each entry
                    }
                }
            }
        }
    }
}
