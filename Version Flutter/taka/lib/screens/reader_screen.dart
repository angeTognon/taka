import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:pdfx/pdfx.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pour sauvegarder la progression
Future<void> saveReadingProgress(Map<String, dynamic> book) async {
  final prefs = await SharedPreferences.getInstance();
  List<String> current = prefs.getStringList('currentlyReading') ?? [];
  current.removeWhere((item) => Map<String, dynamic>.from(jsonDecode(item))['id'] == book['id']);
  current.add(jsonEncode(book));
  await prefs.setStringList('currentlyReading', current);
}

class PdfViewerPage extends StatelessWidget {
  final String pdfUrl;

  const PdfViewerPage({super.key, required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Visualiseur PDF")),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}

class ReaderScreen extends StatefulWidget {
  final Function(String) onNavigate;
  final bool isLoggedIn;
  final String bookTitle;
  final String bookAuthor;
  final int totalPages;
  final String filePath;

  const ReaderScreen({
    super.key,
    required this.onNavigate,
    required this.isLoggedIn,
    required this.bookTitle,
    required this.bookAuthor,
    required this.filePath,
    required this.totalPages,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  bool isDarkMode = false;
  double fontSize = 16.0;
  int currentPage = 1;
  bool showSettings = false;
  bool showNotes = false;

  String selectedText = '';
  List<int> bookmarks = [];
  List<String> highlights = [];
  List<Map<String, dynamic>> notes = [];

  late PdfViewerController _pdfController;
  int? _pdfPageCount;
  int? _pendingRestorePage;

  int get _effectiveTotalPages => (_pdfPageCount ?? widget.totalPages).clamp(1, 100000);

  double get progress {
    final total = _effectiveTotalPages;
    if (total <= 0) return 0;
    return (currentPage / total) * 100;
  }

  @override
  void initState() {
    super.initState();
    _pdfController = PdfViewerController();
    _restoreLastPage();
  }

  Future<void> _restoreLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('currentlyReading') ?? [];
    final book = list
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .firstWhere(
          (b) => b['id'] == widget.bookTitle,
          orElse: () => {},
        );
    if (book.isNotEmpty && book['page'] != null) {
      currentPage = book['page'];
      _pendingRestorePage = book['page'];
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 700;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111827) : Colors.white,
      body: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeader(isMobile: true),
        Expanded(
          child: Column(
            children: [
              _buildReadingControls(isMobile: true),
              Expanded(
                child: Container(
                  color: isDarkMode ? const Color(0xFF111827) : Colors.white,
                  child: ColorFiltered(
                    colorFilter: isDarkMode 
                        ? const ColorFilter.matrix([
                            -0.8,  0,    0,    0, 200, // Rouge inversé avec moins d'intensité
                             0,   -0.8,  0,    0, 200, // Vert inversé avec moins d'intensité
                             0,    0,   -0.8,  0, 200, // Bleu inversé avec moins d'intensité
                             0,    0,    0,    1,   0, // Alpha inchangé
                          ])
                        : const ColorFilter.matrix([
                            1, 0, 0, 0, 0, // Rouge normal
                            0, 1, 0, 0, 0, // Vert normal
                            0, 0, 1, 0, 0, // Bleu normal
                            0, 0, 0, 1, 0, // Alpha normal
                          ]),
                    child: SfPdfViewer.network(
                      widget.filePath,
                      controller: _pdfController,
                      initialZoomLevel: 1.0,
                      canShowScrollHead: false,
                      enableTextSelection: true,
                      enableDoubleTapZooming: true,
                      onTextSelectionChanged: (details) {
                        if (details.selectedText != null && details.selectedText!.isNotEmpty) {
                          setState(() {
                            selectedText = details.selectedText!;
                          });
                          _showTextSelectionMenu(details.selectedText!);
                        }
                      },
                      onPageChanged: (details) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          setState(() {
                            currentPage = details.newPageNumber;
                          });
                          saveReadingProgress({
                            'id': widget.bookTitle,
                            'title': widget.bookTitle,
                            'author': widget.bookAuthor,
                            'progress': ((details.newPageNumber / _effectiveTotalPages) * 100).round(),
                            'lastRead': DateTime.now().toIso8601String(),
                            'page': details.newPageNumber,
                          });
                        });
                      },
                      onDocumentLoaded: (details) {
                        _pdfPageCount = details.document.pages.count;
                        if (_pendingRestorePage != null) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _pdfController.jumpToPage(_pendingRestorePage!);
                            _pendingRestorePage = null;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              _buildWarningMessage(isMobile: true),
            ],
          ),
        ),
        if (showSettings) _buildSettingsPanel(isMobile: true),
        if (showNotes) _buildNotesPanel(isMobile: true),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildHeader(isMobile: false),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildMainContent()),
              if (showSettings) _buildSettingsPanel(isMobile: false),
              if (showNotes) _buildNotesPanel(isMobile: false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader({bool isMobile = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: isMobile ? double.infinity : 1024),
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 16, vertical: isMobile ? 8 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => widget.onNavigate('explore'),
                    icon: const Icon(Icons.chevron_left),
                    label: const Text('Retour'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF97316),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          widget.bookTitle,
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 18,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          widget.bookAuthor,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 14,
                            color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => showSettings = !showSettings),
                        icon: const Icon(Icons.settings),
                        color: isDarkMode ? Colors.white : Colors.black,
                        tooltip: 'Paramètres',
                      ),
                      IconButton(
                        onPressed: () => setState(() => showNotes = !showNotes),
                        icon: const Icon(Icons.menu),
                        color: isDarkMode ? Colors.white : Colors.black,
                        tooltip: 'Annotations',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 4,
              color: const Color(0xFFE5E7EB),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (progress / 100).clamp(0, 1),
                child: Container(
                  color: const Color(0xFFF97316),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadingControls({bool isMobile = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 0, vertical: isMobile ? 8 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: currentPage > 1
                ? () => _pdfController.previousPage()
                : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Page précédente'),
            style: TextButton.styleFrom(
              foregroundColor: currentPage > 1
                  ? const Color(0xFFF97316)
                  : const Color(0xFF9CA3AF),
              textStyle: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
          Text(
            'Page $currentPage sur $_effectiveTotalPages',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          TextButton.icon(
            onPressed: currentPage < _effectiveTotalPages
                ? () => _pdfController.nextPage()
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Page suivante'),
            style: TextButton.styleFrom(
              foregroundColor: currentPage < _effectiveTotalPages
                  ? const Color(0xFFF97316)
                  : const Color(0xFF9CA3AF),
              textStyle: TextStyle(fontSize: isMobile ? 12 : 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1024),
      margin: const EdgeInsets.symmetric(horizontal: 260),
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        children: [
          _buildReadingControls(),
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height - 248,
            width: 800,
            child: Container(
              color: isDarkMode ? const Color(0xFF111827) : Colors.white,
              child: ColorFiltered(
                colorFilter: isDarkMode 
                    ? const ColorFilter.matrix([
                        -0.8,  0,    0,    0, 200, // Rouge inversé avec moins d'intensité
                         0,   -0.8,  0,    0, 200, // Vert inversé avec moins d'intensité
                         0,    0,   -0.8,  0, 200, // Bleu inversé avec moins d'intensité
                         0,    0,    0,    1,   0, // Alpha inchangé
                      ])
                    : const ColorFilter.matrix([
                        1, 0, 0, 0, 0, // Rouge normal
                        0, 1, 0, 0, 0, // Vert normal
                        0, 0, 1, 0, 0, // Bleu normal
                        0, 0, 0, 1, 0, // Alpha normal
                      ]),
                child: SfPdfViewer.network(
                  widget.filePath,
                  controller: _pdfController,
                  initialZoomLevel: 1.0,
                  canShowScrollHead: false,
                  enableTextSelection: true,
                  enableDoubleTapZooming: true,
                  onTextSelectionChanged: (details) {
                    if (details.selectedText != null && details.selectedText!.isNotEmpty) {
                      setState(() {
                        selectedText = details.selectedText!;
                      });
                      _showTextSelectionMenu(details.selectedText!);
                    }
                  },
                  onPageChanged: (details) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        currentPage = details.newPageNumber;
                      });
                      saveReadingProgress({
                        'id': widget.bookTitle,
                        'title': widget.bookTitle,
                        'author': widget.bookAuthor,
                        'progress': ((details.newPageNumber / _effectiveTotalPages) * 100).round(),
                        'lastRead': DateTime.now().toIso8601String(),
                        'page': details.newPageNumber,
                      });
                    });
                  },
                  onDocumentLoaded: (details) {
                    _pdfPageCount = details.document.pages.count;
                    if (_pendingRestorePage != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _pdfController.jumpToPage(_pendingRestorePage!);
                        _pendingRestorePage = null;
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildWarningMessage(),
        ],
      ),
    );
  }

  Widget _buildWarningMessage({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        border: Border.all(color: const Color(0xFFFED7AA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Text('📚', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Lecture uniquement possible via l\'application – aucun téléchargement autorisé',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: const Color(0xFF9A3412),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel({bool isMobile = false}) {
    return Container(
      width: isMobile ? double.infinity : 320,
      color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Paramètres de lecture',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => showSettings = false),
                  icon: const Icon(Icons.close),
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thème',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => isDarkMode = false),
                          icon: const Icon(Icons.wb_sunny, size: 16),
                          label: const Text('Jour'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: !isDarkMode
                                ? const Color(0xFFF97316)
                                : const Color(0xFFF3F4F6),
                            foregroundColor: !isDarkMode
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => setState(() => isDarkMode = true),
                          icon: const Icon(Icons.nightlight_round, size: 16),
                          label: const Text('Nuit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? const Color(0xFFF97316)
                                : const Color(0xFFF3F4F6),
                            foregroundColor: isDarkMode
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Taille de police (UI)',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.text_fields, size: 16),
                      Expanded(
                        child: Slider(
                          value: fontSize,
                          min: 12,
                          max: 24,
                          divisions: 12,
                          onChanged: (value) {
                            setState(() => fontSize = value);
                            // Appliquer le zoom au PDF basé sur la taille de police
                            final zoomLevel = (fontSize - 12) / 12 * 1.5 + 0.5; // Zoom de 0.5 à 2.0
                            _pdfController.zoomLevel = zoomLevel;
                          },
                          activeColor: const Color(0xFFF97316),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${fontSize.round()}px',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Progression',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Page $currentPage / $_effectiveTotalPages',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '${progress.round()}%',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: (progress / 100).clamp(0, 1),
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesPanel({bool isMobile = false}) {
    return Container(
      width: isMobile ? double.infinity : 320,
      color: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mes annotations',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => showNotes = false),
                  icon: const Icon(Icons.close),
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNotesSection(
                    'Signets (${bookmarks.length})',
                    Icons.bookmark,
                    bookmarks.map((page) => ListTile(
                      title: Text('Page $page'),
                      onTap: () {
                        _pdfController.jumpToPage(page);
                        setState(() {
                          currentPage = page;
                        });
                      },
                      dense: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            bookmarks.remove(page);
                          });
                        },
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildNotesSection(
                    'Surlignages (${highlights.length})',
                    Icons.highlight,
                    highlights.map((highlight) => Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '"${highlight.length > 100 ? '${highlight.substring(0, 100)}...' : highlight}"',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildNotesSection(
                    'Notes (${notes.length})',
                    Icons.note,
                    notes.map((note) => Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF374151) : const Color(0xFFDBEAFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Page ${note['page']}',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 18),
                                tooltip: 'Aller à la page',
                                onPressed: () {
                                  final int page = note['page'] as int;
                                  _pdfController.jumpToPage(page);
                                  setState(() {
                                    currentPage = page;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                tooltip: 'Supprimer la note',
                                onPressed: () {
                                  setState(() {
                                    notes.remove(note);
                                  });
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if ((note['text'] as String).isNotEmpty)
                            Text(
                              '"${(note['text'] as String).length > 50 ? '${(note['text'] as String).substring(0, 50)}...' : note['text']}"',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                          if ((note['text'] as String).isNotEmpty) const SizedBox(height: 8),
                          Text(
                            note['note'] as String,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (children.isEmpty)
          Text(
            'Aucun élément',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          )
        else
          ...children,
      ],
    );
  }

  void _showTextSelectionMenu(String selectedText) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Texte sélectionné:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              selectedText.length > 100 ? '${selectedText.substring(0, 100)}...' : selectedText,
              style: TextStyle(
                color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _addBookmark();
                  },
                  icon: const Icon(Icons.bookmark_add, size: 16),
                  label: const Text('Signet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF97316),
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _addHighlight(selectedText);
                  },
                  icon: const Icon(Icons.highlight, size: 16),
                  label: const Text('Surligner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showAddNoteDialog();
                  },
                  icon: const Icon(Icons.note_add, size: 16),
                  label: const Text('Note'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _addBookmark() {
    if (!bookmarks.contains(currentPage)) {
      setState(() {
        bookmarks.add(currentPage);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Signet ajouté à la page $currentPage'),
          backgroundColor: const Color(0xFFF97316),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cette page a déjà un signet'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _addHighlight(String text) {
    if (!highlights.contains(text)) {
      setState(() {
        highlights.add(text);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Texte surligné'),
          backgroundColor: Colors.yellow,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ce texte est déjà surligné'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showAddNoteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1F2937) : Colors.white,
        title: Text(
          'Ajouter une note',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
          ),
          decoration: InputDecoration(
            hintText: 'Votre note...',
            hintStyle: TextStyle(
              color: isDarkMode ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF97316)),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  notes.add({
                    'page': currentPage,
                    'text': selectedText,
                    'note': controller.text.trim(),
                  });
                  selectedText = '';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Note ajoutée'),
                    backgroundColor: Colors.blue,
                  ),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}