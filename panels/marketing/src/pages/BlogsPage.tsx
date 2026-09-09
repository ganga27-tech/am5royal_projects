import React, { useState, useEffect } from 'react';
import { marketingApi } from '../api/marketingApi';
import { BlogItem } from '../types/marketing';
import { Modal } from '../components/common/Modal';
import {
  BookOpenText,
  Plus,
  Trash2,
  Edit3,
  Eye,
  Share2,
  Clock,
  Sparkles,
  Search,
  ExternalLink,
  CheckCircle2,
} from 'lucide-react';

export const BlogsPage: React.FC = () => {
  const [blogs, setBlogs] = useState<BlogItem[]>([]);
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('All');
  const [categoryFilter, setCategoryFilter] = useState('All');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingItem, setEditingItem] = useState<BlogItem | null>(null);
  const [viewingBlog, setViewingBlog] = useState<BlogItem | null>(null);

  // Form states
  const [formTitle, setFormTitle] = useState('');
  const [formSlug, setFormSlug] = useState('');
  const [formCategory, setFormCategory] = useState('Home Care');
  const [formSuperCategory, setFormSuperCategory] = useState('Deep Cleaning');
  const [formAuthor, setFormAuthor] = useState('Aarav Sharma');
  const [formReadTime, setFormReadTime] = useState(5);
  const [formWordCount, setFormWordCount] = useState(1200);
  const [formImage, setFormImage] = useState('');
  const [formMetaTitle, setFormMetaTitle] = useState('');
  const [formMetaDesc, setFormMetaDesc] = useState('');
  const [formKeywords, setFormKeywords] = useState('');
  const [formTags, setFormTags] = useState('');
  const [formContent, setFormContent] = useState('');
  const [formStatus, setFormStatus] = useState<any>('Published');

  const loadData = async () => {
    const list = await marketingApi.getBlogs();
    setBlogs(list);
  };

  useEffect(() => {
    loadData();
  }, []);

  const openCreateModal = () => {
    setEditingItem(null);
    setFormTitle('Top 7 Tips for Sparkling Sofa and Upholstery Maintenance in Indian Weather');
    setFormSlug('sofa-upholstery-maintenance-tips-india');
    setFormCategory('Home Care');
    setFormSuperCategory('Sofa & Upholstery');
    setFormAuthor('Sneha Patel');
    setFormReadTime(6);
    setFormWordCount(1450);
    setFormImage('https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=800');
    setFormMetaTitle('Top 7 Tips for Sofa & Upholstery Care in India • AM5 ROYAL');
    setFormMetaDesc('Keep your fabric and leather sofas stain-free and hygienic with certified partner advice from AM5 ROYAL.');
    setFormKeywords('sofa cleaning tips, upholstery dry cleaning, fabric sofa stain removal');
    setFormTags('Sofa Care, Home Cleaning, DIY Tips, AM5 Royal');
    setFormContent(`# Top 7 Tips for Sparkling Sofa and Upholstery Maintenance

Living rooms are the heart of Indian households. Here is how to protect your furniture from humid weather and stubborn stains.

## 1. Vacuum Dust Mites Weekly
High-filtration vacuuming pulls out micro-allergens before they settle deep into foam cushions.

## 2. Enzyme Cleaners for Coffee & Tea Stains
Never rub fabric vigorously; dab gently with mild enzymatic cleaners.`);
    setFormStatus('Published');
    setIsModalOpen(true);
  };

  const handleEdit = (item: BlogItem) => {
    setEditingItem(item);
    setFormTitle(item.title);
    setFormSlug(item.slug);
    setFormCategory(item.category);
    setFormSuperCategory(item.targetSuperCategory);
    setFormAuthor(item.authorName);
    setFormReadTime(item.readTimeMinutes);
    setFormWordCount(item.wordCount);
    setFormImage(item.featuredImageUrl);
    setFormMetaTitle(item.metaTitle);
    setFormMetaDesc(item.metaDescription);
    setFormKeywords(item.focusKeywords.join(', '));
    setFormTags(item.tags.join(', '));
    setFormContent(item.content);
    setFormStatus(item.status);
    setIsModalOpen(true);
  };

  const handleFormSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    await marketingApi.saveBlog({
      id: editingItem?.id,
      title: formTitle,
      slug: formSlug || formTitle.toLowerCase().replace(/[^a-z0-9]+/g, '-'),
      category: formCategory,
      targetSuperCategory: formSuperCategory,
      authorName: formAuthor,
      readTimeMinutes: Number(formReadTime),
      wordCount: Number(formWordCount),
      featuredImageUrl: formImage || 'https://images.unsplash.com/photo-1527515637462-cff94eecc1ac?w=800',
      metaTitle: formMetaTitle || formTitle,
      metaDescription: formMetaDesc,
      focusKeywords: formKeywords.split(',').map((s) => s.trim()).filter(Boolean),
      tags: formTags.split(',').map((s) => s.trim()).filter(Boolean),
      content: formContent,
      status: formStatus,
      publishDate: editingItem?.publishDate || new Date().toISOString().split('T')[0],
      viewsCount: editingItem?.viewsCount ?? 120,
      sharesCount: editingItem?.sharesCount ?? 15,
    });
    setIsModalOpen(false);
    loadData();
  };

  const handleDelete = async (id: string) => {
    if (confirm('Are you sure you want to delete this blog post?')) {
      await marketingApi.deleteBlog(id);
      loadData();
    }
  };

  const filtered = blogs.filter((b) => {
    const matchesSearch =
      b.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      b.category.toLowerCase().includes(searchQuery.toLowerCase()) ||
      b.targetSuperCategory.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'All' || b.status === statusFilter;
    const matchesCategory = categoryFilter === 'All' || b.category.toLowerCase() === categoryFilter.toLowerCase();
    return matchesSearch && matchesStatus && matchesCategory;
  });

  return (
    <div className="space-y-8 text-left">
      {/* Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-[#EAE2D2] pb-6">
        <div>
          <div className="flex items-center gap-3">
            <div className="p-2.5 rounded-2xl bg-[#FAF6EF] border border-[#E5D8C1] text-[#9B7314] shadow-cream-sm">
              <BookOpenText className="h-6 w-6" />
            </div>
            <div>
              <h1 className="font-serif text-2xl font-bold text-[#1E1B18] tracking-tight">
                Blogs Publishing Studio
              </h1>
              <p className="text-xs sm:text-sm text-[#685D51] mt-0.5">
                Author SEO-optimized articles, manage categories, preview markdown, and track organic view metrics.
              </p>
            </div>
          </div>
        </div>

        <button
          onClick={openCreateModal}
          className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-4 py-2.5 text-xs sm:text-sm font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02] transition-all"
        >
          <Plus className="w-4 h-4" />
          <span>Write New Blog</span>
        </button>
      </div>

      {/* Filter Row */}
      <div className="flex flex-col sm:flex-row items-center justify-between gap-4 p-4 rounded-3xl bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-sm">
        <div className="relative w-full sm:w-80">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-[#8E8276] w-4 h-4" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search blogs by title, category, keywords..."
            className="w-full pl-10 pr-4 py-2 bg-[#FAF7F2] border border-[#EAE2D2] rounded-xl text-xs sm:text-sm text-[#1E1B18] placeholder-[#8E8276] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none transition-all shadow-inner"
          />
        </div>

        <div className="flex items-center gap-2 overflow-x-auto w-full sm:w-auto">
          {['All', 'Published', 'Draft', 'Scheduled'].map((st) => (
            <button
              key={st}
              onClick={() => setStatusFilter(st)}
              className={`rounded-xl px-3.5 py-2 text-xs font-bold transition-all ${
                statusFilter === st
                  ? 'bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] text-[#1E1B18] shadow-cream-sm'
                  : 'bg-[#FAF7F2] border border-[#EAE2D2] text-[#685D51] hover:text-[#1E1B18] hover:bg-[#FFFFFF]'
              }`}
            >
              {st}
            </button>
          ))}
        </div>
      </div>

      {/* Blog Cards Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filtered.map((blog) => (
          <div
            key={blog.id}
            className="glass-card rounded-3xl overflow-hidden bg-[#FFFFFF] border border-[#EAE2D2] shadow-cream-md hover:border-[#C59A27] transition-all flex flex-col justify-between"
          >
            {/* Cover Image */}
            <div className="relative h-48 w-full overflow-hidden bg-[#FAF7F2]">
              <img
                src={blog.featuredImageUrl}
                alt={blog.title}
                className="h-full w-full object-cover transition-transform duration-300 hover:scale-105"
              />
              <div className="absolute top-3 left-3 flex gap-2">
                <span className="rounded-lg bg-[#FFFFFF]/90 backdrop-blur-md px-2.5 py-1 text-[11px] font-extrabold text-[#8A6412] border border-[#E5D8C1] shadow-sm">
                  {blog.category}
                </span>
                <span
                  className={`rounded-lg px-2.5 py-1 text-[11px] font-bold border backdrop-blur-md ${
                    blog.status === 'Published'
                      ? 'bg-emerald-50/90 text-emerald-800 border-emerald-200 shadow-sm'
                      : 'bg-amber-50/90 text-amber-800 border-amber-200 shadow-sm'
                  }`}
                >
                  {blog.status}
                </span>
              </div>
            </div>

            {/* Content Body */}
            <div className="p-6 flex-1 flex flex-col justify-between">
              <div>
                <div className="flex items-center gap-3 text-xs text-[#8E8276] mb-2">
                  <span className="flex items-center gap-1 font-semibold text-[#8A6412]">
                    <Clock className="w-3.5 h-3.5 text-[#9B7314]" />
                    {blog.readTimeMinutes} min read
                  </span>
                  <span>•</span>
                  <span>{blog.publishDate}</span>
                </div>

                <h3
                  onClick={() => setViewingBlog(blog)}
                  className="font-serif text-base sm:text-lg font-bold text-[#1E1B18] hover:text-[#9B7314] transition-colors cursor-pointer line-clamp-2 leading-snug"
                >
                  {blog.title}
                </h3>

                <p className="text-xs text-[#685D51] mt-2 line-clamp-2 leading-relaxed">
                  {blog.metaDescription}
                </p>
              </div>

              {/* Tags & Actions */}
              <div className="mt-5 pt-4 border-t border-[#EAE2D2] flex items-center justify-between">
                <div className="flex items-center gap-3 text-xs text-[#685D51] font-bold">
                  <span className="flex items-center gap-1">
                    <Eye className="w-3.5 h-3.5 text-[#0F4C81]" />
                    {blog.viewsCount.toLocaleString()}
                  </span>
                  <span className="flex items-center gap-1">
                    <Share2 className="w-3.5 h-3.5 text-[#8A6412]" />
                    {blog.sharesCount}
                  </span>
                </div>

                <div className="flex items-center gap-1">
                  <button
                    onClick={() => handleEdit(blog)}
                    className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] hover:bg-[#FFFFFF] p-2 text-[#4D443B] transition-colors"
                    title="Edit Blog"
                  >
                    <Edit3 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => handleDelete(blog.id)}
                    className="rounded-xl border border-rose-200 bg-rose-50 hover:bg-rose-100 p-2 text-rose-700 transition-colors"
                    title="Delete Blog"
                  >
                    <Trash2 className="w-4 h-4" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        ))}
      </div>

      {/* Reader Modal */}
      {viewingBlog && (
        <Modal
          isOpen={!!viewingBlog}
          onClose={() => setViewingBlog(null)}
          title={viewingBlog.title}
          subtitle={`By ${viewingBlog.authorName} • ${viewingBlog.publishDate} • ${viewingBlog.readTimeMinutes} min read`}
          maxWidth="max-w-3xl"
        >
          <div className="space-y-4 text-left">
            <img
              src={viewingBlog.featuredImageUrl}
              alt={viewingBlog.title}
              className="w-full h-64 object-cover rounded-2xl border border-[#EAE2D2]"
            />
            <div className="max-w-none text-xs sm:text-sm text-[#4D443B] whitespace-pre-line leading-relaxed p-4 bg-[#FAF7F2] rounded-2xl border border-[#EAE2D2]">
              {viewingBlog.content}
            </div>
          </div>
        </Modal>
      )}

      {/* Create / Edit Modal */}
      <Modal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        title={editingItem ? 'Edit Blog Article' : 'Draft New Blog Article'}
        subtitle="Fill title, slug, SEO tags, reading time, and content body"
        maxWidth="max-w-3xl"
      >
        <form onSubmit={handleFormSubmit} className="space-y-4 text-left">
          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Blog Article Title
            </label>
            <input
              type="text"
              required
              value={formTitle}
              onChange={(e) => setFormTitle(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:bg-[#FFFFFF] focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Category
              </label>
              <input
                type="text"
                value={formCategory}
                onChange={(e) => setFormCategory(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Target Super Category
              </label>
              <input
                type="text"
                value={formSuperCategory}
                onChange={(e) => setFormSuperCategory(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Author Name
              </label>
              <input
                type="text"
                value={formAuthor}
                onChange={(e) => setFormAuthor(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Featured Image URL
            </label>
            <input
              type="url"
              value={formImage}
              onChange={(e) => setFormImage(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Meta Description (for SERP ranking)
            </label>
            <textarea
              rows={2}
              value={formMetaDesc}
              onChange={(e) => setFormMetaDesc(e.target.value)}
              className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
            />
          </div>

          <div>
            <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
              Markdown Content Body
            </label>
            <textarea
              rows={6}
              value={formContent}
              onChange={(e) => setFormContent(e.target.value)}
              className="w-full font-mono rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3.5 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
            />
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Read Time (Mins)
              </label>
              <input
                type="number"
                value={formReadTime}
                onChange={(e) => setFormReadTime(Number(e.target.value))}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-xs font-bold uppercase tracking-wider text-[#4D443B] mb-1">
                Publishing Status
              </label>
              <select
                value={formStatus}
                onChange={(e) => setFormStatus(e.target.value)}
                className="w-full rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-3 py-2 text-xs text-[#1E1B18] focus:border-[#C59A27] focus:outline-none"
              >
                <option value="Published">Published</option>
                <option value="Draft">Draft</option>
                <option value="Scheduled">Scheduled</option>
                <option value="In Review">In Review</option>
              </select>
            </div>
          </div>

          <div className="flex justify-end gap-3 pt-4 border-t border-[#EAE2D2]">
            <button
              type="button"
              onClick={() => setIsModalOpen(false)}
              className="rounded-xl border border-[#EAE2D2] bg-[#FAF7F2] px-4 py-2 text-xs font-bold text-[#685D51] hover:bg-[#FFFFFF] transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="rounded-xl bg-gradient-to-r from-[#C59A27] via-[#DAB84E] to-[#C59A27] px-5 py-2 text-xs font-bold text-[#1E1B18] shadow-cream-md hover:scale-[1.02]"
            >
              {editingItem ? 'Save Blog Changes' : 'Publish Blog'}
            </button>
          </div>
        </form>
      </Modal>
    </div>
  );
};

