using UnityEngine;
using Random = UnityEngine.Random;


public class FlappyBirdController : MonoBehaviour
{
    private enum GameState
    {
        None = 0,
        Menu = 1,
        Playing = 2,
        GameOver = 3
    }

    private static readonly int TitleBobAmplitude = Shader.PropertyToID("_TitleBobAmplitude");
    private static readonly int TitleBobSpeed = Shader.PropertyToID("_TitleBobSpeed");
    private static readonly int PressSpaceAlphaMin = Shader.PropertyToID("_PressSpaceAlphaMin");
    private static readonly int PressSpacePulseSpeed = Shader.PropertyToID("_PressSpacePulseSpeed");
    private static readonly int BirdY = Shader.PropertyToID("_BirdY");
    private static readonly int PipeXPosition = Shader.PropertyToID("_PipeXPosition");
    private static readonly int PipeYPosition = Shader.PropertyToID("_PipeYPosition");
    private static readonly int BirdX = Shader.PropertyToID("_BirdX");
    private static readonly int Score = Shader.PropertyToID("_Score");
    private static readonly int State = Shader.PropertyToID("_GameState");

    
    [SerializeField] private Material flappyBirdGameMaterial;
    [SerializeField] InputService inputService;
    [SerializeField] private float minPipeY = 0.1f;
    [SerializeField] private float maxPipeY = 0.25f;
    [SerializeField] private float gravity = 9.8f;
    [SerializeField] private float jumpForce = 5f;
    [SerializeField] private float birdStartY = 0.74f;
    [SerializeField] private float birdStartX = 0.2f;
    [SerializeField] private float birdMinY = 0.53f;
    [SerializeField] private float birdMaxY = 0.875f;
    [SerializeField] private float pipeStartX = 0.7f;
    [SerializeField] private float pipeMoveSpeed = 5f;
    [SerializeField] private float pipeResetX = 1.2f;
    [SerializeField] private float pipeOffscreenX = -0.5f;

    
    private int score;
    private float birdY;
    private float velocity;
    private float pipeX;
    private bool hasScored;
    private GameState currentGameState;
    


    private void Start()
    {
        ChangeState(GameState.Menu);
    }


    private void Update()
    {
        if (currentGameState == GameState.Playing)
        {
            UpdateGameplay();
        }
    }


    private void OnDestroy()
    {
        UnsubscribeFromInput();
        inputService.Dispose();
    }



    private void ChangeState(GameState newState)
    {
        if (currentGameState == newState) return;

        flappyBirdGameMaterial.SetFloat(State, (int)newState);
        ExitCurrentState();
        currentGameState = newState;
        EnterNewState();
    }


    private void ExitCurrentState()
    {
        switch (currentGameState)
        {
            case GameState.Menu:
                ExitMenuState();
                break;
            case GameState.Playing:
                ExitPlayState();
                break;
            case GameState.GameOver:
                ExitGameOverState();
                break;
        }
    }


    private void EnterNewState()
    {
        switch (currentGameState)
        {
            case GameState.Menu:
                EnterMenuState();
                break;
            case GameState.Playing:
                EnterPlayState();
                break;
            case GameState.GameOver:
                EnterGameOverState();
                break;
        }
    }

        
    private void EnterMenuState()
    {
        inputService.OnSpacePressed += StartGame;
        ResetGame();
    
        if (flappyBirdGameMaterial != null)
        {
            flappyBirdGameMaterial.SetFloat(TitleBobAmplitude, 0.02f);
            flappyBirdGameMaterial.SetFloat(TitleBobSpeed, 1.5f);
            flappyBirdGameMaterial.SetFloat(PressSpaceAlphaMin, 0.3f);
            flappyBirdGameMaterial.SetFloat(PressSpacePulseSpeed, 2.0f);
        }

    }


    private void ExitMenuState()
    {
        inputService.OnSpacePressed -= StartGame;
    }


    private void EnterPlayState()
    {
        inputService.OnSpacePressed += Jump;
        InitializeGameplay();
    }


    private void ExitPlayState()
    {
        inputService.OnSpacePressed -= Jump;
    }


    private void EnterGameOverState()
    {
        inputService.OnSpacePressed += RestartGame;
        velocity = 0f;
    }


    private void ExitGameOverState()
    {
        inputService.OnSpacePressed -= RestartGame;
    }



    private void StartGame()
    {
        ChangeState(GameState.Playing);
    }


    private void RestartGame()
    {
        ChangeState(GameState.Menu);
    }


    private void ResetGame()
    {
        score = 0;
        hasScored = false;
        UpdateMaterialProperties();
    }


    private void InitializeGameplay()
    {
        birdY = birdStartY;
        pipeX = pipeStartX;
        velocity = 0f;
        hasScored = false;
        GenerateNewPipe();
        UpdateMaterialProperties();
    }


    private void UpdateGameplay()
    {
        UpdateBirdPosition();
        MovePipe();
        UpdateScore();
        CheckCollisions();
    }


    private void Jump()
    {
        velocity = jumpForce;
    }


    private void UpdateBirdPosition()
    {
        velocity -= gravity * Time.deltaTime;
        birdY += velocity * Time.deltaTime;
        birdY = Mathf.Clamp(birdY, 0f, 1f);

        UpdateBirdMaterial();
    }


    private void MovePipe()
    {
        pipeX -= pipeMoveSpeed * Time.deltaTime;

        if (pipeX <= pipeOffscreenX)
        {
            ResetPipe();
        }

        UpdatePipeMaterial();
    }


    private void ResetPipe()
    {
        pipeX = pipeResetX;
        GenerateNewPipe();
        hasScored = false;
    }


    private void GenerateNewPipe()
    {
        float randomHeight = Random.Range(minPipeY, maxPipeY);

        if (flappyBirdGameMaterial != null)
        {
            flappyBirdGameMaterial.SetFloat(PipeYPosition, randomHeight);
        }
    }


    private void UpdateScore()
    {
        if (birdStartX >= pipeX && !hasScored)
        {
            score++;
            hasScored = true;
            UpdateScoreMaterial();
        }
    }


    private void CheckCollisions()
    {
        if (birdY <= birdMinY || birdY >= birdMaxY)
        {
            ChangeState(GameState.GameOver);
        }
    }

    
    private void UpdateMaterialProperties()
    {
        if (flappyBirdGameMaterial == null) return;

        flappyBirdGameMaterial.SetFloat(BirdY, birdY);
        flappyBirdGameMaterial.SetFloat(BirdX, birdStartX);
        flappyBirdGameMaterial.SetFloat(Score, score);
        flappyBirdGameMaterial.SetFloat(PipeXPosition, pipeX);
    }


    private void UpdateBirdMaterial()
    {
        if (flappyBirdGameMaterial != null)
        {
            flappyBirdGameMaterial.SetFloat(BirdY, birdY);
        }
    }


    private void UpdatePipeMaterial()
    {
        if (flappyBirdGameMaterial != null)
        {
            flappyBirdGameMaterial.SetFloat(PipeXPosition, pipeX);
        }
    }


    private void UpdateScoreMaterial()
    {
        if (flappyBirdGameMaterial != null)
        {
            flappyBirdGameMaterial.SetFloat(Score, score);
        }
    }



    private void UnsubscribeFromInput()
    {
        if (inputService == null) return;

        inputService.OnSpacePressed -= StartGame;
        inputService.OnSpacePressed -= Jump;
        inputService.OnSpacePressed -= RestartGame;
    }
}