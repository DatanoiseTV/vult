#include "PluginProcessor.h"
#include "PluginEditor.h"

demoAudioProcessorEditor::demoAudioProcessorEditor (demoAudioProcessor& p)
    : juce::AudioProcessorEditor (&p), audioProcessor (p)
{
    setSize (400, 300);
    c_slider.setSliderStyle(juce::Slider::Rotary);
    c_slider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
    addAndMakeVisible(c_slider);
    v_slider.setSliderStyle(juce::Slider::Rotary);
    v_slider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
    addAndMakeVisible(v_slider);
    ch_slider.setSliderStyle(juce::Slider::Rotary);
    ch_slider.setTextBoxStyle(juce::Slider::TextBoxBelow, false, 80, 20);
    addAndMakeVisible(ch_slider);
    c_label.setText("c", juce::dontSendNotification);
    c_label.attachToComponent(&c_slider, false);
    addAndMakeVisible(c_label);
    v_label.setText("v", juce::dontSendNotification);
    v_label.attachToComponent(&v_slider, false);
    addAndMakeVisible(v_label);
    ch_label.setText("ch", juce::dontSendNotification);
    ch_label.attachToComponent(&ch_slider, false);
    addAndMakeVisible(ch_label);
    c_slider.onValueChange = [this] {
        audioProcessor.c = c_slider.getValue();
    };
    v_slider.onValueChange = [this] {
        audioProcessor.v = v_slider.getValue();
    };
    ch_slider.onValueChange = [this] {
        audioProcessor.ch = ch_slider.getValue();
    };
    c_slider.setValue(audioProcessor.c, juce::dontSendNotification);
    v_slider.setValue(audioProcessor.v, juce::dontSendNotification);
    ch_slider.setValue(audioProcessor.ch, juce::dontSendNotification);
}

demoAudioProcessorEditor::~demoAudioProcessorEditor() {}

void demoAudioProcessorEditor::paint (juce::Graphics& g)
{
    g.fillAll (getLookAndFeel().findColour (juce::ResizableWindow::backgroundColourId));
    c_slider.setBounds(20, 30, 93, 250);
    v_slider.setBounds(153, 30, 93, 250);
    ch_slider.setBounds(286, 30, 93, 250);
}

void demoAudioProcessorEditor::resized() {}