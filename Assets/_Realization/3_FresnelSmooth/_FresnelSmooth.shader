Shader "Dima/_FresnelSmooth"
{
    Properties
    {
        _Color ("ColorAlbedo", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        _Occlusion ("Occlusion", 2D) = "white" {}
        _Emission ("Emission", 2D) = "white" {}
        _Normal ("NormalMap", 2D) = "bump" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _TimeScale("TimeScale",Range(0,10)) = 1.0
        [HideInInspector] _texcoord( "", 2D ) = "white" {}
    }
    SubShader
    {
        Tags { "Queue" = "Overlay" }
        CGPROGRAM
        #pragma surface surf Standard addshadow
        #pragma target 3.0
        //TEX2D + TRANSFORM_TEX : Делает UV со смещением и размером потом делает текстуру и возращает её
        #define Trform2D(name,tex) (tex2D(name,tex.xy * name##_ST.xy + name##_ST.zw))
        //Remap : Переназначить число из одного диапазона в другой
        #define Remap(s,a1,a2,b1,b2) (b1 + (s - a1) * (b2 - b1)/(a2 - a1))

        struct Input
        {
            float2 uv_texcoord;
            float3 viewDir;
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;

        sampler2D _Occlusion;
        float4 _Occlusion_ST;

        sampler2D _Emission;
        float4 _Emission_ST;

        sampler2D _Normal;
        float4 _Normal_ST;

        half _Glossiness;
        half _Metallic;
        half _TimeScale;
        fixed4 _Color;

        void surf (Input i, inout SurfaceOutputStandard o){
            //Пинг-Понг число аниманиции
            float TimeSin = Remap(sin(_Time.y * _TimeScale),-1.0,1.0,8,2);

            float3 Normal = UnpackNormal(Trform2D(_Normal,i.uv_texcoord));
            float FresnelTime = pow(1.0 - saturate(dot(Normal,normalize(i.viewDir))),TimeSin);

            o.Albedo = (Trform2D(_MainTex,i.uv_texcoord) * _Color).rgb;
            o.Occlusion = Trform2D(_Occlusion,i.uv_texcoord).rgb;
            o.Emission = Trform2D(_Emission,i.uv_texcoord).rgb + FresnelTime;
            o.Normal = Normal;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
