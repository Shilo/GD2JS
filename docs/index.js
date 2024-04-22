var countText = document.getElementById('count');
var decrementButton = document.getElementById('decrement-button');

decrementButton.disabled = true;

document.addEventListener('GD2JSLoaded', () => {
    GD2JS.connect('value_changed', onValueChanged)
    decrementButton.disabled = false;
});

document.body.addEventListener('click', () => GD2JS.call_meta('unfocus_godot'));

function decrement() {
    GD2JS.updateMeta('value', (value) => {
        value -= 1;
        GD2JS.emit_signal('value_changed', value);
        return value;
    }, 0);
}

function onValueChanged(value) {
    countText.textContent = value;
}