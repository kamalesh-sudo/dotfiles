import QtQuick

QtObject {

    // ============================================================
    // POSITION
    // ============================================================

    readonly property string position: "top"
    readonly property string alignment: "center"
    readonly property int margin: 0


    // ============================================================
    // SIZE
    // ============================================================

    readonly property int visualizerWidth: 550
    readonly property int visualizerHeight: 200

    readonly property real maximumHeight: 45
    readonly property real minimumHeight: 0


    // ============================================================
    // DYNAMIC PALETTE
    // ============================================================

    readonly property bool usePalette: true

    readonly property string paletteFile:
        "~/.cache/ryoku/colors.json"

    readonly property var paletteKeys: [
        "primary",
        "secondary",
        "tertiary"
    ]

    readonly property color visualizerColor: "#ffffff"


    // ============================================================
    // SPECTRUM
    // ============================================================

    // More bars = finer detail
    readonly property int barCount: 96


    // ============================================================
    // OVERALL AUDIO SENSITIVITY
    // ============================================================

    // Responsive without constantly hitting maximum height
    readonly property real sensitivity: 1.35


    // ============================================================
    // AUDIO RESPONSE
    // ============================================================

    // Fast attack
    readonly property real attack: 0.018

    // Short, controlled falloff
    readonly property real decay: 0.075

    // Small amount of smoothing
    readonly property real smoothing: 0.025


    // ============================================================
    // FREQUENCY BALANCE
    // ============================================================

    // Strong kick / bass
    readonly property real bassBoost: 0.95

    // Proper mids
    readonly property real midBoost: 0.55

    // Clearly visible highs
    readonly property real highBoost: 0.32


    // ============================================================
    // RIDGES / WAVE SHAPE
    // ============================================================

    // Sharp but not spiky
    readonly property real ridgeSharpness: 1.65

    // Slight blending between neighboring bars
    readonly property real waveSmooth: 0.035


    // ============================================================
    // TRANSIENT / BEAT REACTION
    // ============================================================

    // Kick/snare/hats react strongly
    readonly property real beatSensitivity: 1.20

    // Short beat response
    readonly property real beatDecay: 0.18


    // ============================================================
    // SPECTRUM MAPPING
    // ============================================================

    // More natural frequency distribution
    readonly property real frequencyCurve: 0.72

    // Bass concentrated toward center
    readonly property real centerBassWeight: 1.35

    // Extra center energy, but controlled
    readonly property real centerBassEnergy: 0.65

    // Keep treble visible around edges
    readonly property real edgeHighWeight: 0.85


    // ============================================================
    // TRANSIENT FREQUENCY WEIGHTS
    // ============================================================

    readonly property real bassTransientWeight: 1.30
    readonly property real midTransientWeight: 1.10
    readonly property real highTransientWeight: 1.00


    // ============================================================
    // TRANSIENT THRESHOLD
    // ============================================================

    // Ignore tiny background fluctuations
    readonly property real transientThreshold: 0.025

    // Moderate transient amplification
    readonly property real transientMultiplier: 3.20

    // Beat visibly pushes the waveform
    readonly property real beatPulseStrength: 1.15
}
