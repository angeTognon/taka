<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class FaqController extends Controller
{
    public function authors()
    {
        return view('faq.authors');
    }

    public function readers()
    {
        return view('faq.readers');
    }
}
