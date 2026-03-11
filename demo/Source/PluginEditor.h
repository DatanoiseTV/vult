#pragma once

#include <JuceHeader.h>
#include "PluginProcessor.h"

class demoAudioProcessorEditor  : public juce::AudioProcessorEditor
{
public:
    demoAudioProcessorEditor (demoAudioProcessor&);
    ~demoAudioProcessorEditor() override;

    void paint (juce::Graphics&) override;
    void resized() override;

private:
    demoAudioProcessor& audioProcessor;

    juce::Slider c_slider;
    juce::Slider v_slider;
    juce::Slider ch_slider;
    juce::Label c_label;
    juce::Label v_label;
    juce::Label ch_label;

    JUCE_DECLARE_NON_COPYABLE_WITH_LEAK_DETECTOR (demoAudioProcessorEditor)
};