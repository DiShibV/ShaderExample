Shader "Dima/_NoiseShow"
{
    Properties
    {
        _Color ("ColorAlbedo", Color) = (1,1,1,1)
        _MainTex ("Albedo", 2D) = "white" {}
        _Occlusion ("Occlusion", 2D) = "white" {}
        _Emission ("Emission", 2D) = "white" {}
        _Normal ("NormalMap", 2D) = "bump" {}
        _NoiseTexture ("NoiseTexture", 2D) = "white" {}
        _BurnRamp ("Burn Ramp", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _TimeScale ("TimeScale", Range(0,2)) = 0.0

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
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;

        sampler2D _Occlusion;
        float4 _Occlusion_ST;

        sampler2D _Emission;
        float4 _Emission_ST;

        sampler2D _Normal;
        float4 _Normal_ST;

        sampler2D _NoiseTexture;
        float4 _NoiseTexture_ST;

        sampler2D _BurnRamp;

        half _Glossiness;
        half _Metallic;
        half _TimeScale;
        fixed4 _Color;

        void surf (Input i, inout SurfaceOutputStandard o)
        {
            fixed TimeSin = Remap(abs(sin(_Time.y * _TimeScale)), 0.0, 1.0, 0.5, -0.2);
            fixed Noise = saturate(Remap(
                Trform2D(_NoiseTexture, i.uv_texcoord).r + TimeSin,
                0.0, 1.0, -4.0, 4.0));
            fixed4 Ramp = tex2D(_BurnRamp, Noise);
            o.Albedo = (Trform2D(_MainTex,i.uv_texcoord) * _Color).rgb;
            o.Occlusion = Trform2D(_Occlusion,i.uv_texcoord).rgb;
            o.Emission = (Trform2D(_Emission,i.uv_texcoord) + Ramp).rgb;
            o.Normal = UnpackNormal(Trform2D(_Normal,i.uv_texcoord));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            clip(Noise - 0.5);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
