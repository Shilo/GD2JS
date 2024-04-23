var countText = document.getElementById('count');
var decrementButton = document.getElementById('decrement-button');

decrementButton.disabled = true;

document.addEventListener('gd2js-loaded', () => {
    GD2JS.connect(GD2JS.EventType.META_CHANGED, onMetaChanged)
    document.body.addEventListener('click', () => GD2JS.call_meta('unfocus_godot'));

    decrementButton.disabled = false;
    decrementButton = undefined;
});

function decrement() {
    GD2JS.updateMeta('count', (value) => value - 1, 0);
}

function onMetaChanged(name, value, oldValue) {
    if (name !== 'count') return;

    countText.textContent = value;
}