Shader "Dima/_SlicesLine"
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

        _LinePropagation ("LinePropagation", Range(0,50)) = 5.0
        _TimeScale ("TimeScale", Range(0,5)) = 0.1

        [HideInInspector] _texcoord( "", 2D ) = "white" {}
    }
    SubShader
    {
        Tags { "Queue" = "Overlay" }
        CGPROGRAM
        #pragma surface surf Standard addshadow
        #pragma target 3.0

        #define Trform2D(name,tex) (tex2D(name,tex.xy * name##_ST.xy + name##_ST.zw))
        #define Remap(s,a1,a2,b1,b2) (b1 + (s - a1) * (b2 - b1)/(a2 - a1))

        struct Input
        {
            float2 uv_texcoord;
            float3 worldPos;
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
        fixed4 _Color;

        half _TimeScale;
        half _LinePropagation;

        void surf (Input i, inout SurfaceOutputStandard o){
            o.Albedo = (Trform2D(_MainTex,i.uv_texcoord) * _Color).rgb;
            o.Occlusion = Trform2D(_Occlusion,i.uv_texcoord).rgb;
            o.Emission = Trform2D(_Emission,i.uv_texcoord).rgb;
            o.Normal = UnpackNormal(Trform2D(_Normal,i.uv_texcoord));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            float Time = Remap(_SinTime.w * _TimeScale,-1.0,1.0,0.0,0.3);
            clip(frac(i.worldPos.y * _LinePropagation)-Time);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
