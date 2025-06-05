using System;
using UnityEngine;
using UnityEngine.InputSystem;


public class InputService : MonoBehaviour
{
    private InputActions inputActions;
    public event Action OnSpacePressed;
    public event Action OnMouseDown;
    public event Action OnMouseUp;


    private void Start()
    {
        inputActions = new InputActions();
        inputActions.Player.Enable();

        inputActions.Player.SpacePressed.performed += SpacePressed;
        inputActions.Player.MouseHold.performed += MouseDown;
        inputActions.Player.MouseHold.canceled += MouseUp;
    }


    
    private void SpacePressed(InputAction.CallbackContext obj)
    {
        OnSpacePressed?.Invoke();
    }


    private void MouseDown(InputAction.CallbackContext obj)
    {
        OnMouseDown?.Invoke();
    }


    private void MouseUp(InputAction.CallbackContext obj)
    {
        OnMouseUp?.Invoke();
    }

    
    public void Dispose()
    {
        inputActions.Player.Disable();
    }


    public Vector2 GetMouseDelta()
    {
        return inputActions.Player.MouseDelta.ReadValue<Vector2>();
    }
}
