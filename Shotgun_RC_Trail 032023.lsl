integer mynum=0;//Position in list, this is your shot's stride. Has to be manually set :(
float max=75;//Max distance on this tracer, scales the end alpha by this. Manually set this too.
vector DecodeBase64ToPos(string base64)
{
    float x = (float)llBase64ToInteger("AAA" + llGetSubString(base64, 0, 2)) / 10;
    float y = (float)llBase64ToInteger("AAA" + llGetSubString(base64, 3, 5)) / 10;
    float z = (float)llBase64ToInteger("AA" + llGetSubString(base64, 6, 9)) / 10;
    return <x, y, z>;
}
default
{
    on_rez(integer n)
    {
        if(n)
        {
            key rezzer = llList2Key(llGetObjectDetails(llGetKey(), [OBJECT_REZZER_KEY]), 0);
            string data = (string)llGetObjectDetails(rezzer, [OBJECT_TEXT]);
            vector src=llGetPos();
            string part=llList2String(llParseString2List(data,["|"],[]),mynum);//Gets your strided data
            vector end=DecodeBase64ToPos(part);//Decodes into a vector from base64
            float dist=1-(llVecDist(src,end)/max);
            if(dist>1)dist=1;
            if(dist<1)dist=0;
llLinkParticleSystem(-1,[
PSYS_PART_FLAGS,PSYS_PART_RIBBON_MASK|PSYS_PART_INTERP_SCALE_MASK|PSYS_PART_INTERP_COLOR_MASK|PSYS_PART_EMISSIVE_MASK,
PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
PSYS_PART_BLEND_FUNC_SOURCE, PSYS_PART_BF_SOURCE_ALPHA,
PSYS_PART_BLEND_FUNC_DEST, PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
PSYS_SRC_TEXTURE,"3dd352d0-e84f-c4cd-7341-521bb04b6751",
PSYS_SRC_BURST_RATE,.1,
PSYS_SRC_BURST_SPEED_MIN,0,
PSYS_SRC_BURST_SPEED_MAX,.1,
PSYS_SRC_ANGLE_BEGIN, 0,//PI, 
PSYS_SRC_ANGLE_END, 0,//PI*2,
PSYS_PART_MAX_AGE,.7,
PSYS_SRC_BURST_PART_COUNT,1,
PSYS_PART_START_GLOW,.05,
PSYS_PART_END_GLOW,0,
PSYS_PART_START_SCALE,<.3,6,6>,
PSYS_PART_END_SCALE,<0,6,6>, //.015,.015
PSYS_PART_START_COLOR,<0.941, 0.831, 0.231>,
PSYS_PART_END_COLOR,<0.941, 0.831, 0.231>,
PSYS_PART_START_ALPHA,.6,
PSYS_PART_END_ALPHA,.6*dist]);
llLinkParticleSystem(2,[]);
            llSetLinkPrimitiveParamsFast(LINK_THIS,[PRIM_ROTATION,llRotBetween(<1,0,0>,end-src)]);
            llSleep(.1);
            llSetRegionPos(end);
            //llTriggerSound(llList2String([],(integer)llFrand(4)),.4); //Add your sounds here!
                llLinkParticleSystem(2,[
                        PSYS_PART_FLAGS,0 |PSYS_PART_EMISSIVE_MASK|PSYS_PART_INTERP_COLOR_MASK|PSYS_PART_INTERP_SCALE_MASK,
                        PSYS_SRC_PATTERN,PSYS_SRC_PATTERN_ANGLE_CONE,
                        PSYS_SRC_BURST_RADIUS,0.1,
                        PSYS_SRC_ANGLE_BEGIN,0, 
                        PSYS_SRC_ANGLE_END,0,
                        PSYS_SRC_TARGET_KEY,llGetKey(),
                        PSYS_PART_START_COLOR,<0.899, 0.861, 0.461>,
                        PSYS_PART_END_COLOR,<0.899, 0.861, 0.461>,
                        PSYS_PART_START_ALPHA,0.25,
                        PSYS_PART_END_ALPHA,0,
                        PSYS_PART_START_GLOW,0.3,
                        PSYS_PART_END_GLOW,0,
                        PSYS_PART_BLEND_FUNC_SOURCE,PSYS_PART_BF_SOURCE_ALPHA,
                        PSYS_PART_BLEND_FUNC_DEST,PSYS_PART_BF_ONE_MINUS_SOURCE_ALPHA,
                        PSYS_PART_START_SCALE,<.85,.85,0>,
                        PSYS_PART_END_SCALE,<.01125,.01125,0>,
                        PSYS_SRC_TEXTURE,"d09d7b3e-48b2-94a2-0dd3-fea8e922fb7d",
                        PSYS_SRC_MAX_AGE,.35,
                        PSYS_PART_MAX_AGE,.5,
                        PSYS_SRC_BURST_RATE,.5,
                        PSYS_SRC_BURST_PART_COUNT,2,
                        PSYS_SRC_ACCEL,<0,0,0>,
                        PSYS_SRC_OMEGA,<0,0,0>,
                        PSYS_SRC_BURST_SPEED_MIN,.1,
                        PSYS_SRC_BURST_SPEED_MAX,.1]);
            llSleep(2);
            llDie();
        }   
    }
}
