Shader "Dima/_AnimationDistort"
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

        [HDR]_ColorDistor("ColorDistor",Color) = (1,1,1,1)
        _TextureNoise("TextureNoise",2D) = "white" {}
        _DistortTexture("DistortTexture",2D) = "bump" {}
        _MaskSurface("MaskSurface",2D) = "white" {}
        _IntensityDistort("intensityDistort",Range(0,1)) = 1.0
        _UVSizeNormal("UVSizeNormal",Range(0,0.1)) = 0.04
        _TimeScale("TimeScale",Range(0,1)) = 0.0
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

        sampler2D _TextureNoise;
        float4 _TextureNoise_ST;

        sampler2D _DistortTexture;
        float4 _DistortTexture_ST;

        sampler2D _MaskSurface;

        half _Glossiness;
        half _Metallic;
        half _TimeScale;
        fixed _UVSizeNormal;
        fixed _IntensityDistort;
        fixed4 _Color;
        fixed4 _ColorDistor;

        void surf (Input i, inout SurfaceOutputStandard o){
            float TimeMove = _Time.y * _TimeScale;
            float3 DistortTexture = UnpackScaleNormal(Trform2D(_DistortTexture,i.uv_texcoord),_UVSizeNormal);
            float3 Noise1 = tex2D(_TextureNoise, i.uv_texcoord * _TextureNoise_ST.xy + ((TimeMove * -1 + i.uv_texcoord) + DistortTexture));
            float3 Noise2 = tex2D(_TextureNoise, i.uv_texcoord * _TextureNoise_ST.xy + ((TimeMove * float2(1.0,0.5) + i.uv_texcoord) + DistortTexture));
            float MaskSurf = tex2D(_MaskSurface,i.uv_texcoord).r * _IntensityDistort;
            float3 animation = (Noise1 * Noise2 * _ColorDistor) * MaskSurf;
            o.Albedo = animation + (Trform2D(_MainTex,i.uv_texcoord) * _Color) * (1.0 - MaskSurf);
            o.Emission = animation + Trform2D(_Emission,i.uv_texcoord) * (1.0 - MaskSurf);
            o.Occlusion = Trform2D(_Occlusion,i.uv_texcoord).rgb;
            o.Normal = UnpackNormal(Trform2D(_Normal,i.uv_texcoord));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
