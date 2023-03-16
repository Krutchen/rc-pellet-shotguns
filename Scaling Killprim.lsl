key t=NULL_KEY;
default
{
    on_rez(integer pass)
    {
        if(pass!=0)
        {
            list av = llGetAgentList(AGENT_LIST_REGION,[]);
            integer len = llGetListLength(av);
            while(len)
            {   
                key tgtkey = llList2Key(av,--len);
                if((integer)("0x"+llGetSubString((string)tgtkey,0,3)) == ((pass >> 16) & 0xFFFF))
                {
                    integer dmg=pass&0xFF;
                    string text=" - "+(string)dmg+" DMG";
                    llSetObjectName(llGetObjectName()+text);
                    llSetDamage(dmg);
                    t=tgtkey;
                    llResetTime();
                    @loop;
                    list d=llGetObjectDetails(t,[OBJECT_POS]);
                    vector pos=llList2Vector(d,0);
                    if(llGetParcelFlags(pos)&0x00000020||llGetRegionFlags()&0x1)
                    {   
                        llSetLinkPrimitiveParamsFast(0,[PRIM_PHYSICS,0,PRIM_PHANTOM,1]);
                        llSetRegionPos(pos);
                        llSetLinkPrimitiveParamsFast(0,[PRIM_PHYSICS,1,PRIM_PHANTOM,0]);
                    }
                    llSleep(.2);
                    if(llGetTime()<5)jump loop;
                    llDie();
                }
            }
            llDie();
        }
    }
}
