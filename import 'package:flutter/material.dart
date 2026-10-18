import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SkillAssessmentPage extends StatefulWidget {
  final String playerId;
  final String playerName;

  const SkillAssessmentPage({Key? key, required this.playerId, required this.playerName}) : super(key: key);

  @override
  _SkillAssessmentPageState createState() => _SkillAssessmentPageState();
}

class _SkillAssessmentPageState extends State<SkillAssessmentPage> {
  final _formKey = GlobalKey<FormState>();
  double _passing = 0.0;
  double _controlling = 0.0;
  double _dribbling = 0.0;
  double _heading = 0.0;
  double _shooting = 0.0;
  bool _isLoading = false;

  Future<void> _saveAssessment() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await FirebaseFirestore.instance.collection('players').doc(widget.playerId).update({
          'passing': _passing,
          'controlling': _controlling,
          'dribbling': _dribbling,
          'heading': _heading,
          'shooting': _shooting,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        // Simpan juga ke riwayat penilaian (history)
        await FirebaseFirestore.instance.collection('assessments_history').add({
          'playerId': widget.playerId,
          'passing': _passing,
          'controlling': _controlling,
          'dribbling': _dribbling,
          'heading': _heading,
          'shooting': _shooting,
          'date': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nilai skill berhasil disimpan secara real-time!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Penilaian Skill: ${widget.playerName}'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Form Penilaian Keterampilan Dasar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              const SizedBox(height: 20),
              _buildSlider('Passing (Mengoper)', _passing, (val) => setState(() => _passing = val)),
              _buildSlider('Controlling (Mengontrol)', _controlling, (val) => setState(() => _controlling = val)),
              _buildSlider('Dribbling (Menggiring)', _dribbling, (val) => setState(() => _dribbling = val)),
              _buildSlider('Heading (Menyundul)', _heading, (val) => setState(() => _heading = val)),
              _buildSlider('Shooting (Menembak)', _shooting, (val) => setState(() => _shooting = val)),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _isLoading ? null : _saveAssessment,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Nilai Skill', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}