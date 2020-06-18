using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class SwitchElements : MonoBehaviour
{
    public Text Label;
    private int _index = 0;
    private List<GameObject> _switchArray = new List<GameObject>();

    private void Start() {
        foreach (Transform child in transform)
             _switchArray.Add(child.gameObject);
        Switch();
    }

    public void Next() {
        if(_index >= _switchArray.Count - 1) return;
        _index++;
        Switch();
    }

    public void Prev() {
        if (_index == 0) return;
        _index--;
        Switch();
    }

    private void Switch() {
        _switchArray.ForEach((g) => g.SetActive(false));
        _switchArray[_index].SetActive(true);
        Label.text = _switchArray[_index].name;
    }
}
