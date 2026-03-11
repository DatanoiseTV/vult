#include "PluginProcessor.h"
#include "PluginEditor.h"

#include "../demo.h"
#include "../demo.tables.h"

static double vult_sample_rate = 44100.0;
extern "C" {
    float float_samplerate() { return (float)vult_sample_rate; }
    int32_t fix_samplerate() { return (int32_t)(vult_sample_rate * 65536.0); }
}



demoAudioProcessor::demoAudioProcessor()
#ifndef JucePlugin_PreferredChannelConfigurations
     : juce::AudioProcessor (BusesProperties()
                     #if ! JucePlugin_IsMidiEffect
                      #if ! JucePlugin_IsSynth
                       .withInput  ("Input",  juce::AudioChannelSet::stereo(), true)
                      #endif
                       .withOutput ("Output", juce::AudioChannelSet::stereo(), true)
                     #endif
                       )
#endif
{
    Demo_process_init(process_ctx);
    Demo_default(process_ctx);
    c = 0.0f;
    v = 0.0f;
    ch = 0.0f;
}

demoAudioProcessor::~demoAudioProcessor() {}

const juce::String demoAudioProcessor::getName() const { return JucePlugin_Name; }

bool demoAudioProcessor::acceptsMidi() const
{
   #if JucePlugin_WantsMidiInput
    return true;
   #else
    return false;
   #endif
}

bool demoAudioProcessor::producesMidi() const
{
   #if JucePlugin_ProducesMidiOutput
    return true;
   #else
    return false;
   #endif
}

bool demoAudioProcessor::isMidiEffect() const
{
   #if JucePlugin_IsMidiEffect
    return true;
   #else
    return false;
   #endif
}

double demoAudioProcessor::getTailLengthSeconds() const { return 0.0; }
int demoAudioProcessor::getNumPrograms() { return 1; }
int demoAudioProcessor::getCurrentProgram() { return 0; }
void demoAudioProcessor::setCurrentProgram (int) {}
const juce::String demoAudioProcessor::getProgramName (int) { return {}; }
void demoAudioProcessor::changeProgramName (int, const juce::String&) {}

void demoAudioProcessor::prepareToPlay (double sampleRate, int)
{
    vult_sample_rate = sampleRate;
    Demo_process_init(process_ctx);
    Demo_default(process_ctx);
}
void demoAudioProcessor::releaseResources() {}

#ifndef JucePlugin_PreferredChannelConfigurations
bool demoAudioProcessor::isBusesLayoutSupported (const BusesLayout& layouts) const
{
  #if JucePlugin_IsMidiEffect
    juce::ignoreUnused (layouts);
    return true;
  #else
    if (layouts.getMainOutputChannelSet() != juce::AudioChannelSet::mono()
     && layouts.getMainOutputChannelSet() != juce::AudioChannelSet::stereo())
        return false;
   #if ! JucePlugin_IsSynth
    if (layouts.getMainOutputChannelSet() != layouts.getMainInputChannelSet())
        return false;
   #endif
    return true;
  #endif
}
#endif

void demoAudioProcessor::processBlock (juce::AudioBuffer<float>& buffer, juce::MidiBuffer& midiMessages)
{
    juce::ScopedNoDenormals noDenormals;
    auto totalNumInputChannels  = getTotalNumInputChannels();
    auto totalNumOutputChannels = getTotalNumOutputChannels();

    for (auto i = totalNumInputChannels; i < totalNumOutputChannels; ++i)
        buffer.clear (i, 0, buffer.getNumSamples());

    Demo_controlChange(process_ctx, 98, c * 127.0f, 0);
    Demo_controlChange(process_ctx, 24, v * 127.0f, 0);
    Demo_controlChange(process_ctx, 114, ch * 127.0f, 0);

    float inputs[1];
    float outputs[2];

    for (int channel = 0; channel < totalNumInputChannels; ++channel)
    {
        for (int j = 0; j < buffer.getNumSamples(); j++) {
            inputs[0] = buffer.getSample(channel, j);
            Demo_process(process_ctx, inputs[0]);
            outputs[0] = Demo_process_ret_0(process_ctx);
            outputs[1] = Demo_process_ret_1(process_ctx);
            buffer.setSample(channel, j, outputs[0]);
            buffer.setSample(channel, j, outputs[1]);
        }
    }
}

bool demoAudioProcessor::hasEditor() const { return true; }
juce::AudioProcessorEditor* demoAudioProcessor::createEditor()
{
    return new demoAudioProcessorEditor (*this);
}

void demoAudioProcessor::getStateInformation (juce::MemoryBlock&) {}
void demoAudioProcessor::setStateInformation (const void*, int) {}

juce::AudioProcessor* JUCE_CALLTYPE createPluginFilter()
{
    return new demoAudioProcessor();
}