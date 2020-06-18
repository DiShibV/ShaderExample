Shader "Dima/_AnimationFire"
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

        _Tileable ("Tileable", 2D) = "white" {}
        _Mask ("Mask", 2D) = "white" {}
        _TileSpeed ("TimeSpeed",Vector) = (0,0,0,0)
        _TileableIntensity ("TileableIntensity",Range(0,2)) = 1.0

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

        sampler2D _Tileable;

        sampler2D _Mask;
        float4 _Mask_ST;

        float2 _TileSpeed;
        half _TileableIntensity;

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input i, inout SurfaceOutputStandard o){
            float2 TimeTile = _Time.x * _TileSpeed + i.uv_texcoord;
            float3 Emission = Trform2D(_Mask,i.uv_texcoord) * tex2D(_Tileable,TimeTile);
            Emission *= (_TileableIntensity * (_SinTime.w + 1.5));
            Emission += Trform2D(_Emission,i.uv_texcoord);
            o.Albedo = (Trform2D(_MainTex,i.uv_texcoord) * _Color).rgb;
            o.Occlusion = Trform2D(_Occlusion,i.uv_texcoord).rgb;
            o.Emission = Emission;
            o.Normal = UnpackNormal(Trform2D(_Normal,i.uv_texcoord));
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
