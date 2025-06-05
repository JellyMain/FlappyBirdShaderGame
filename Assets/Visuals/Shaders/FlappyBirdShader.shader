Shader "Unlit/FlappyBirdShader"
{
    Properties
    {
        _Color("FoilColor", Color) = (1,1,1,1)
        _ColorDensity("ColorDensity", Float) = 1.0
        _TitleAmplitude("TitleAmplitude", Range(0, 0.1)) = 0.02
        _TitleSpeed("TitleSpeed", Range(0, 5)) = 1.5
        _PressSpaceAlphaMin("PressSpaceMinAlpha", Range(0, 1)) = 0.2
        _PressSpacePulseSpeed("PressSpacePulseSpeed", Range(0, 5)) = 2.0


        _GameOverTexture("GameOverTexture", 2D) = "" { }
        _GameOverPosition("GameOverPosition", Vector) = (0, 0, 0, 1)
        _GameOverScale("GameOverScale", Vector) = (0, 0, 0, 1)
        _GameOverScaleAmplitude("GameOverScaleAmplitude", Float) = 1.0
        _GameOverScaleSpeed("GameOverScaleSpeed", Float) = 0.0

        _BirdY("BirdYPosition", Range(0,1)) = 0.5
        _BirdSpawnPosition("BirdSpawnPosition", Vector) = (0.3, 0.5, 0, 1)
        _MainTex("BirdTexture", 2D) = "white" { }
        _BirdX("BirdX", Range(0,1)) = 0.0
        _BirdScale("BirdScale", Vector) = (0.2, 0.2, 0, 1)

        _BackgroundTexture("BackgroundTexture", 2D) = "" { }
        _BackgroundPosition("BackgroundPosition", Vector) = (0, 0, 0, 1)
        _BackgroundScale("BackgroundScale", Vector) =(1,1,1,1)

        _PipeYPosition("PipeYPosition", Range(0,1)) = 0.5
        _PipeXPosition("PipeXPosition", Float) = 0.7
        _PipeTexture("PipeTexture", 2D) = "" { }
        _PipeScale("PipeScale", Vector) = (0, 0, 0, 1)

        _Score("Score", Float) = 0
        _ScorePosition("ScorePosition", Vector) = (0, 0, 0, 1)
        _ScoreScale("ScoreScale", Float) = 0.0

        _GameState("GameState", Float) = 0.0

        _TitleTexture("TitleTexture", 2D) = "" { }
        _TitlePosition("TitlePosition", Vector) = (0, 0, 0, 1)
        _TitleScale("TitleScale", Vector) = (0, 0, 0, 1)

        _PressSpaceToStartTexture("PressSpaceToStartTexture", 2D) = "" { }
        _PressSpaceToStartPosition("PressSpaceToStartPosition", Vector) = (0, 0, 0, 1)
        _PressSpaceToStartScale("PressSpaceToStartScale", Vector) = (0, 0, 0, 1)

        _CardTexture("CardTexture", 2D) = "" { }
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _BackgroundTexture;
            sampler2D _PipeTexture;
            sampler2D _TitleTexture;
            sampler2D _PressSpaceToStartTexture;
            sampler2D _CardTexture;
            sampler2D _GameOverTexture;
            int _Score;
            float4 _PipeScale;
            float4 _ScorePosition;
            float4 _TitleScale;
            float4 _TitlePosition;
            float4 _PressSpaceToStartPosition;
            float4 _PressSpaceToStartScale;
            float4 _BackgroundPosition;
            float4 _BackgroundScale;
            float4 _GameOverScale;
            float4 _GameOverPosition;
            float4 _BirdScale;
            float4 _BirdSpawnPosition;
            fixed4 _Color;
            float _BirdY;
            float _PipeYPosition;
            float _PipeXPosition;
            float _ScoreScale;
            float _BirdX;
            float _GameState;
            float _ColorDensity;
            float _TitleAmplitude;
            float _TitleSpeed;
            float _PressSpaceAlphaMin;
            float _PressSpacePulseSpeed;
            float _GameOverScaleAmplitude;
            float _GameOverScaleSpeed;
            


            float drawHorizontalSegment(float2 uv, float y, float width, float height)
            {
                float2 center = float2(0.5, y);
                float2 size = float2(width, height);
                float2 d = abs(uv - center) - size * 0.5;
                return step(max(d.x, d.y), 0.0);
            }

            float drawVerticalSegment(float2 uv, float x, float yCenter, float width, float height)
            {
                float2 center = float2(x, yCenter);
                float2 size = float2(width, height);
                float2 d = abs(uv - center) - size * 0.5;
                return step(max(d.x, d.y), 0.0);
            }

            float segmentTop(float2 uv) { return drawHorizontalSegment(uv, 0.85, 0.6, 0.1); } // Top
            float segmentTopRight(float2 uv) { return drawVerticalSegment(uv, 0.75, 0.675, 0.1, 0.25); } // Top right
            float segmentBottomRight(float2 uv) { return drawVerticalSegment(uv, 0.75, 0.325, 0.1, 0.25); } // Bottom right
            float segmentBottom(float2 uv) { return drawHorizontalSegment(uv, 0.15, 0.6, 0.1); } // Bottom
            float segmentBottomLeft(float2 uv) { return drawVerticalSegment(uv, 0.25, 0.325, 0.1, 0.25); } // Bottom left
            float segmentTopLeft(float2 uv) { return drawVerticalSegment(uv, 0.25, 0.675, 0.1, 0.25); } // Top left
            float segmentMiddle(float2 uv) { return drawHorizontalSegment(uv, 0.5, 0.6, 0.1); } // Middle

            float drawDigit(float2 uv, int digit)
            {
                if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0)
                {
                    return 0.0;
                }

                float result = 0;

                if (digit == 0)
                {
                    result = max(result, segmentTop(uv));
                    result = max(result, segmentTopRight(uv));
                    result = max(result, segmentBottomRight(uv));
                    result = max(result, segmentBottom(uv));
                    result = max(result, segmentBottomLeft(uv));
                    result = max(result, segmentTopLeft(uv));
                }
                else if (digit == 1)
                {
                    result = max(result, segmentTopRight(uv));
                    result = max(result, segmentBottomRight(uv));
                }
                else if (digit == 2)
                {
                    result = max(result, segmentTop(uv));
                    result = max(result, segmentTopRight(uv));
                    result = max(result, segmentMiddle(uv));
                    result = max(result, segmentBottomLeft(uv));
                    result = max(result, segmentBottom(uv));
                }
                else if (digit == 3)
                {
                    result = max(result, segmentTop(uv));
                    result = max(result, segmentTopRight(uv));
                    result = max(result, segmentMiddle(uv));
                    result = max(result, segmentBottomRight(uv));
                    result = max(result, segmentBottom(uv));
                }
                else if (digit == 4)
                {
                    result = max(result, segmentTopLeft(uv));
                    result = max(result, segmentMiddle(uv));
                    result = max(result, segmentTopRight(uv));
                    result = max(result, segmentBottomRight(uv));
                }
                else if (digit == 5)
                {
                    result = max(result, segmentTop(uv));
                    result = max(result, segmentTopLeft(uv));
                    result = max(result, segmentMiddle(uv));
                    result = max(result, segmentBottomRight(uv));
                    result = max(result, segmentBottom(uv));
                }
                else if (digit == 6)
                {
                    result = max(result, segmentTop(uv));
                    result = max(result, segmentTopLeft(uv));
                    result = max(result, segmentMiddle(uv));
                    result = max(result, segmentBottomLeft(uv));
                    result = max(result, segmentBottom(uv));
                    result = max(result, segmentBottomRight(uv));
                }
                else if (digit == 7)
                {
                    result = max(result, segmentTop(uv));
                    result = max(result, segmentTopRight(uv));
                    result = max(result, segmentBottomRight(uv));
                }
                else if (digit == 8)
                {
                    result = max(result, segmentTop(uv));
                    result = max(result, segmentTopRight(uv));
                    result = max(result, segmentBottomRight(uv));
                    result = max(result, segmentBottom(uv));
                    result = max(result, segmentBottomLeft(uv));
                    result = max(result, segmentTopLeft(uv));
                    result = max(result, segmentMiddle(uv));
                }
                else if (digit == 9)
                {
                    result = max(result, segmentTop(uv));
                    result = max(result, segmentTopRight(uv));
                    result = max(result, segmentBottomRight(uv));
                    result = max(result, segmentBottom(uv));
                    result = max(result, segmentTopLeft(uv));
                    result = max(result, segmentMiddle(uv));
                }

                return result;
            }


            float drawScore(float2 uv, uint score)
            {
                float result = 0;

                if (score < 10)
                {
                    float2 digitUV = (uv - _ScorePosition.xy) / _ScoreScale;
                    result = drawDigit(digitUV, score);
                }
                else if (score < 100)
                {
                    uint tens = score / 10;
                    uint ones = score % 10;

                    float2 tensUV = (uv - _ScorePosition.xy + float2(0.04, 0)) / _ScoreScale;
                    float2 onesUV = (uv - _ScorePosition.xy - float2(0.04, 0)) / _ScoreScale;

                    result = max(drawDigit(tensUV, tens), drawDigit(onesUV, ones));
                }
                else if (score < 1000)
                {
                    uint hundreds = score / 100;
                    uint tens = (score % 100) / 10;
                    uint ones = score % 10;

                    float2 hundredsUV = (uv - _ScorePosition.xy - float2(-0.09, 0)) / _ScoreScale;
                    float2 tensUV = (uv - _ScorePosition.xy - float2(0.01, 0)) / _ScoreScale;
                    float2 onesUV = (uv - _ScorePosition.xy - float2(0.09, 0)) / _ScoreScale;

                    result = max(result, drawDigit(hundredsUV, hundreds));
                    result = max(result, drawDigit(tensUV, tens));
                    result = max(result, drawDigit(onesUV, ones));
                }

                return result;
            }


            fixed4 drawBird(float2 uv)
            {
                float2 birdPosition = float2(_BirdX, _BirdY);
                float2 birdUV = (uv - birdPosition) / _BirdScale.xy + 0.5;

                fixed4 birdColor = fixed4(0, 0, 0, 0);

                if (birdUV.x >= 0 && birdUV.x <= 1 && birdUV.y >= 0 && birdUV.y <= 1)
                {
                    birdColor = tex2D(_MainTex, birdUV);
                }

                return birdColor;
            }


            fixed4 drawPipe(float2 uv)
            {
                float2 pipePosition = float2(_PipeXPosition, _PipeYPosition);
                float2 pipeUV = (uv - pipePosition) / _PipeScale.xy + 0.5;

                fixed4 pipeColor = fixed4(0, 0, 0, 0);

                if (pipeUV.x >= 0 && pipeUV.x <= 1 && pipeUV.y >= 0 && pipeUV.y <= 1)
                {
                    pipeColor = tex2D(_PipeTexture, pipeUV);
                }

                return pipeColor;
            }


            fixed4 drawTitle(float2 uv)
            {
                float titleOffset = _TitleAmplitude * sin(_Time.y * _TitleSpeed);

                float2 titlePosition = _TitlePosition.xy + float2(0, titleOffset);

                float2 titleUV = (uv - titlePosition) / _TitleScale.xy + 0.5;
                fixed4 titleColor = fixed4(0, 0, 0, 0);

                if (titleUV.x >= 0 && titleUV.x <= 1 && titleUV.y >= 0 && titleUV.y <= 1)
                {
                    titleColor = tex2D(_TitleTexture, titleUV);
                }

                return titleColor;
            }


            fixed4 drawBackground(float2 uv)
            {
                float2 backgroundUV = (uv - _BackgroundPosition.xy) / _BackgroundScale.xy + 0.5;
                fixed4 backgroundColor = fixed4(0, 0, 0, 0);
                if (backgroundUV.x >= 0 && backgroundUV.x <= 1 && backgroundUV.y >= 0 && backgroundUV.y <= 1)
                {
                    backgroundColor = tex2D(_BackgroundTexture, backgroundUV);
                }

                return backgroundColor;
            }


            fixed4 drawScoreOverlay(float2 uv)
            {
                float scoreAlpha = drawScore(uv, _Score);
                return fixed4(1, 1, 1, scoreAlpha);
            }


            fixed4 drawPressSpaceToStart(float2 uv)
            {
                float2 pressSpaceToStartUV = (uv - _PressSpaceToStartPosition.xy) / _PressSpaceToStartScale + 0.5;
                fixed4 pressSpaceToStartColor = fixed4(0, 0, 0, 0);

                if (pressSpaceToStartUV.x >= 0 && pressSpaceToStartUV.x <= 1 && pressSpaceToStartUV.y >= 0 &&
                    pressSpaceToStartUV.y <= 1)
                {
                    pressSpaceToStartColor = tex2D(_PressSpaceToStartTexture, pressSpaceToStartUV);

                    float alphaMultiplier = lerp(_PressSpaceAlphaMin, 1.0,
                                                 (sin(_Time.y * _PressSpacePulseSpeed) + 1.0) * 0.5);

                    pressSpaceToStartColor.a *= alphaMultiplier;
                }

                return pressSpaceToStartColor;
            }


            fixed4 drawCard(float2 uv)
            {
                fixed4 cardColor = tex2D(_CardTexture, uv);

                if (cardColor.a < 0.01)
                {
                    return fixed4(0, 0, 0, 0);
                }

                return cardColor;
            }


            fixed4 drawGameOver(float2 uv)
            {

                float2 gameOverScaleOffset = _GameOverScaleAmplitude * sin(_Time.y * _GameOverScaleSpeed);
                float2 gameOverUV = (uv - _GameOverPosition) / (_GameOverScale.xy + gameOverScaleOffset) + 0.5;
                fixed4 gameOverColor = fixed4(0, 0, 0, 0);

                if (gameOverUV.x >= 0 && gameOverUV.x <= 1 && gameOverUV.y >= 0 && gameOverUV.y <= 1)
                {
                    gameOverColor = tex2D(_GameOverTexture, gameOverUV);
                }

                return gameOverColor;
            }
            

            struct objectData
            {
                float4 vertex: POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };


            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 tangentSpaceViewDir : TEXCOORD1;
            };


            v2f vert(objectData v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldViewDir = normalize(_WorldSpaceCameraPos - worldPos);

                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
                float3 worldBitangent = cross(worldNormal, worldTangent) * v.tangent.w;

                float3x3 tangentToWorld = float3x3(worldTangent, worldBitangent, worldNormal);
                o.tangentSpaceViewDir = mul(transpose(tangentToWorld), worldViewDir);

                return o;
            }


            void Unity_Hue_Normalized_float(float3 In, float Offset, out float3 Out)
            {
                float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
                float4 P = lerp(float4(In.bg, K.wz), float4(In.gb, K.xy), step(In.b, In.g));
                float4 Q = lerp(float4(P.xyw, In.r), float4(In.r, P.yzx), step(P.x, In.r));
                float D = Q.x - min(Q.w, Q.y);
                float E = 1e-10;
                float V = (D == 0) ? Q.x : (Q.x + E);
                float3 hsv = float3(abs(Q.z + (Q.w - Q.y) / (6.0 * D + E)), D / (Q.x + E), V);

                float hue = hsv.x + Offset;
                hsv.x = (hue < 0)
                                          ? hue + 1
                                          : (hue > 1)
                                          ? hue - 1
                                          : hue;

                float4 K2 = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
                float3 P2 = abs(frac(hsv.xxx + K2.xyz) * 6.0 - K2.www);
                Out = hsv.z * lerp(K2.xxx, saturate(P2 - K2.xxx), hsv.y);
            }

            
            fixed4 applyFoilEffect(float3 tangentSpaceViewDir, fixed4 baseColor)
            {
                float hueOffset = _ColorDensity * tangentSpaceViewDir.x * tangentSpaceViewDir.y;

                float3 hueShiftedColor;
                Unity_Hue_Normalized_float(_Color.rgb, hueOffset, hueShiftedColor);

                float3 finalColor = hueShiftedColor * baseColor.rgb;

                return fixed4(finalColor, baseColor.a);
            }


            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 finalColor;

                if (_GameState == 1)
                {
                    fixed4 titleColor = drawTitle(i.uv);
                    fixed4 pressSpaceToStartColor = drawPressSpaceToStart(i.uv);
                    fixed4 backgroundColor = drawBackground(i.uv);
                    fixed4 cardColor = drawCard(i.uv);

                    fixed4 layer1 = lerp(backgroundColor, cardColor, cardColor.a);
                    fixed4 layer2 = lerp(layer1, titleColor, titleColor.a);
                    fixed4 layer3 = lerp(layer2, pressSpaceToStartColor, pressSpaceToStartColor.a);

                    finalColor = layer3;
                }
                else if (_GameState == 2)
                {
                    fixed4 cardColor = drawCard(i.uv);
                    fixed4 birdColor = drawBird(i.uv);
                    fixed4 pipeColor = drawPipe(i.uv);
                    fixed4 backgroundColor = drawBackground(i.uv);
                    fixed4 scoreColor = drawScoreOverlay(i.uv);

                    fixed4 layer1 = lerp(backgroundColor, birdColor, birdColor.a);
                    fixed4 layer2 = lerp(layer1, pipeColor, pipeColor.a);
                    fixed4 layer3 = lerp(layer2, scoreColor, scoreColor.a);
                    fixed4 layer4 = lerp(layer3, cardColor, cardColor.a);

                    finalColor = layer4;
                }
                else if (_GameState == 3)
                {
                    fixed4 gameOverColor = drawGameOver(i.uv);
                    fixed4 backgroundColor = drawBackground(i.uv);
                    fixed4 cardColor = drawCard(i.uv);

                    fixed4 layer1 = lerp(backgroundColor, cardColor, cardColor.a);
                    fixed4 layer2 = lerp(layer1, gameOverColor, gameOverColor.a);

                    finalColor = layer2;
                }
                else
                {
                    finalColor = fixed4(1, 1, 1, 1);
                }

                return applyFoilEffect(i.tangentSpaceViewDir, finalColor);
            }
            ENDCG
        }
    }
}