import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart' show kPrimary, kTextPri, kTextSec;

// ── Barre de recherche ────────────────────────────────────────────────────────
class SearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  const SearchField({super.key, required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.inter(color: kTextPri, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: kTextSec, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: kTextSec, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ── Chip coloré ───────────────────────────────────────────────────────────────
class ColorChip extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;
  const ColorChip({
    super.key,
    required this.label,
    required this.color,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── État chargement ───────────────────────────────────────────────────────────
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2),
    );
  }
}

// ── État erreur ───────────────────────────────────────────────────────────────
class ErrorState extends StatelessWidget {
  final String message;
  const ErrorState({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Erreur : $message',
        style: GoogleFonts.inter(color: kTextSec),
      ),
    );
  }
}

// ── État vide ─────────────────────────────────────────────────────────────────
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: kTextSec.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.inter(color: kTextSec, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Titre de section ──────────────────────────────────────────────────────────
class ScreenTitle extends StatelessWidget {
  final String title;
  const ScreenTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
          color: kTextPri,
        ),
      ),
    );
  }
}
