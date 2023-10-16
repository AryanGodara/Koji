use orion::operators::tensor::{Tensor, U32Tensor,};
use orion::numbers::i32;

use koji::midi::types::{
    Midi, Message, Modes, ArpPattern, VelocityCurve, SetTempo, TimeSignature, NoteOn, NoteOff
};

trait MidiTrait {
    /// =========== NOTE MANIPULATION ===========
    /// Instantiate a Midi.
    fn new() -> Midi;
    /// Set a message in a Midi object.
    fn set_message(self: @Midi, msg: Message) -> Midi;
    /// Transpose notes by a given number of semitones.
    fn transpose_notes(self: @Midi, semitones: i32) -> Midi;
    ///  Reverse the order of notes.
    fn reverse_notes(self: @Midi) -> Midi;
    /// Align notes to a given rhythmic grid.
    fn quantize_notes(self: @Midi, grid_size: usize) -> Midi;
    /// Extract notes within a specified pitch range.
    fn extract_notes(self: @Midi, note_range: usize) -> Midi;
    /// Change the duration of notes by a given factor
    fn change_note_duration(self: @Midi, factor: i32) -> Midi;
    /// =========== GLOBAL MANIPULATION ===========
    /// Alter the tempo of the Midi data.
    fn change_tempo(self: @Midi, new_tempo: u32) -> Midi;
    /// Change instrument patches based on a provided mapping
    fn remap_instruments(self: @Midi, chanel: u32) -> Midi;
    /// =========== ANALYSIS ===========
    /// Extract the tempo (in BPM) from the Midi data.
    fn get_bpm(self: @Midi) -> u32;
    /// Return statistics about notes (e.g., most frequent note, average note duration).
    /// =========== ADVANCED MANIPULATION ===========
    /// Add harmonies to existing melodies based on specified intervals.
    fn generate_harmony(self: @Midi, modes: Modes) -> Midi;
    /// Convert chords into arpeggios based on a given pattern.
    fn arpeggiate_chords(self: @Midi, pattern: ArpPattern) -> Midi;
    /// Add or modify dynamics (velocity) of notes based on a specified curve or pattern.
    fn edit_dynamics(self: @Midi, curve: VelocityCurve) -> Midi;
}

impl MidiImpl of MidiTrait {
    fn new() -> Midi {
        Midi { events: array![].span() }
    }

    fn set_message(self: @Midi, msg: Message) -> Midi {
        panic(array!['not supported yet'])
    }

    fn transpose_notes(self: @Midi, semitones: i32) -> Midi {
        let mut ev = self.clone().events;
        let mut eventlist = ArrayTrait::<Message>::new();

        loop {
            match ev.pop_front() {
                Option::Some(currentevent) => {
                    match currentevent {
                        Message::NOTE_ON(NoteOn) => {
                            let outnote = if semitones.sign {
                                *NoteOn.note - semitones.mag.try_into().unwrap()
                            } else {
                                *NoteOn.note + semitones.mag.try_into().unwrap()
                            };

                            let newnote = NoteOn {
                                channel: *NoteOn.channel,
                                note: outnote,
                                velocity: *NoteOn.velocity,
                                time: *NoteOn.time
                            };
                            let notemessage = Message::NOTE_ON((newnote));
                            eventlist.append(notemessage);
                        },
                        Message::NOTE_OFF(NoteOff) => {
                            let outnote = if semitones.sign {
                                *NoteOff.note - semitones.mag.try_into().unwrap()
                            } else {
                                *NoteOff.note + semitones.mag.try_into().unwrap()
                            };

                            let newnote = NoteOff {
                                channel: *NoteOff.channel,
                                note: outnote,
                                velocity: *NoteOff.velocity,
                                time: *NoteOff.time
                            };
                            let notemessage = Message::NOTE_OFF((newnote));
                            eventlist.append(notemessage);
                        },
                        Message::SET_TEMPO(SetTempo) => {
                            eventlist.append(*currentevent);
                        },
                        Message::TIME_SIGNATURE(TimeSignature) => {
                            eventlist.append(*currentevent);
                        },
                        Message::CONTROL_CHANGE(ControlChange) => {
                            eventlist.append(*currentevent);
                        },
                        Message::PITCH_WHEEL(PitchWheel) => {
                            eventlist.append(*currentevent);
                        },
                        Message::AFTER_TOUCH(AfterTouch) => {
                            eventlist.append(*currentevent);
                        },
                        Message::POLY_TOUCH(PolyTouch) => {
                            eventlist.append(*currentevent);
                        },
                    }
                },
                Option::None(_) => {
                    break;
                }
            };
        };

        Midi { events: eventlist.span() }
    }

    fn reverse_notes(self: @Midi) -> Midi {
        panic(array!['not supported yet'])
    }

    fn quantize_notes(self: @Midi, grid_size: usize) -> Midi {
        panic(array!['not supported yet'])
    }

    fn extract_notes(self: @Midi, note_range: usize) -> Midi {
        let mut ev = self.clone().events;

        let middlec = 60;
        let mut lowerbound = 0;
        let mut upperbound = 127;

        if note_range < middlec {
            lowerbound = middlec - note_range;
        }
        if note_range + middlec < 127 {
            upperbound = middlec + note_range;
        }

        let mut eventlist = ArrayTrait::<Message>::new();

        loop {
            match ev.pop_front() {
                Option::Some(currentevent) => {
                    match currentevent {
                        Message::NOTE_ON(NoteOn) => {
                            let currentnoteon = *NoteOn.note;
                            if currentnoteon > lowerbound.try_into().unwrap()
                                && currentnoteon < upperbound.try_into().unwrap() {
                                eventlist.append(*currentevent);
                            }
                        },
                        Message::NOTE_OFF(NoteOff) => {
                            let currentnoteoff = *NoteOff.note;
                            if currentnoteoff > lowerbound.try_into().unwrap()
                                && currentnoteoff < upperbound.try_into().unwrap() {
                                eventlist.append(*currentevent);
                            }
                        },
                        Message::SET_TEMPO(SetTempo) => {},
                        Message::TIME_SIGNATURE(TimeSignature) => {},
                        Message::CONTROL_CHANGE(ControlChange) => {},
                        Message::PITCH_WHEEL(PitchWheel) => {},
                        Message::AFTER_TOUCH(AfterTouch) => {},
                        Message::POLY_TOUCH(PolyTouch) => {},
                    }
                },
                Option::None(_) => {
                    break;
                }
            };
        };

        // Create a new Midi object with the modified event list
        Midi { events: eventlist.span() }
    }


    fn change_note_duration(self: @Midi, factor: i32) -> Midi {
        panic(array!['not supported yet'])
    }

    fn change_tempo(self: @Midi, new_tempo: u32) -> Midi {
        // Create a clone of the MIDI events
        let mut ev = self.clone().events;

        // Create a new array to store the modified events
        let mut eventlist = ArrayTrait::<Message>::new();

        loop {
            // Use pop_front to get the next event
            match ev.pop_front() {
                Option::Some(currentevent) => {
                    // Process the current event
                    match currentevent {
                        Message::NOTE_ON(NoteOn) => {
                            eventlist.append(*currentevent);
                        },
                        Message::NOTE_OFF(NoteOff) => {
                            eventlist.append(*currentevent);
                        },
                        Message::SET_TEMPO(SetTempo) => {
                            // Create a new SetTempo message with the updated tempo
                            let tempo = SetTempo { tempo: new_tempo, time: *SetTempo.time };
                            let tempomessage = Message::SET_TEMPO((tempo));
                            eventlist.append(tempomessage);
                        },
                        Message::TIME_SIGNATURE(TimeSignature) => {
                            eventlist.append(*currentevent);
                        },
                        Message::CONTROL_CHANGE(ControlChange) => {
                            eventlist.append(*currentevent);
                        },
                        Message::PITCH_WHEEL(PitchWheel) => {
                            eventlist.append(*currentevent);
                        },
                        Message::AFTER_TOUCH(AfterTouch) => {
                            eventlist.append(*currentevent);
                        },
                        Message::POLY_TOUCH(PolyTouch) => {
                            eventlist.append(*currentevent);
                        },
                    }
                },
                Option::None(_) => {
                    // If there are no more events, break out of the loop
                    break;
                }
            };
        };

        // Create a new Midi object with the modified event list
        Midi { events: eventlist.span() }
    }

    fn remap_instruments(self: @Midi, chanel: u32) -> Midi {
        panic(array!['not supported yet'])
    }

    fn get_bpm(self: @Midi) -> u32 {
        // Iterate through the MIDI events, find and return the SetTempo message
        let mut ev = self.clone().events;
        let mut outtempo: u32 = 0;

        loop {
            match ev.pop_front() {
                Option::Some(currentevent) => {
                    match currentevent {
                        Message::NOTE_ON(NoteOn) => {},
                        Message::NOTE_OFF(NoteOff) => {},
                        Message::SET_TEMPO(SetTempo) => {
                            outtempo = *SetTempo.tempo;
                        },
                        Message::TIME_SIGNATURE(TimeSignature) => {},
                        Message::CONTROL_CHANGE(ControlChange) => {},
                        Message::PITCH_WHEEL(PitchWheel) => {},
                        Message::AFTER_TOUCH(AfterTouch) => {},
                        Message::POLY_TOUCH(PolyTouch) => {},
                    }
                },
                Option::None(_) => {
                    break;
                }
            };
        };

        outtempo
    }

    fn generate_harmony(self: @Midi, modes: Modes) -> Midi {
        panic(array!['not supported yet'])
    }

    fn arpeggiate_chords(self: @Midi, pattern: ArpPattern) -> Midi {
        panic(array!['not supported yet'])
    }

    fn edit_dynamics(self: @Midi, curve: VelocityCurve) -> Midi {
        panic(array!['not supported yet'])
    }
}

