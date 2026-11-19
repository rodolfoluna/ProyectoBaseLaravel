<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class DatabaseSeederTest extends TestCase
{
    use RefreshDatabase;

    public function test_setup_can_be_repeated_without_overwriting_student_changes(): void
    {
        $this->seed();

        $user = User::where('email', 'test@example.com')->sole();
        $this->assertTrue(Hash::check('password', $user->password));

        $user->update(['name' => 'Nombre editado', 'password' => 'clave-personal']);
        $this->seed();

        $this->assertDatabaseCount('users', 1);
        $this->assertSame('Nombre editado', $user->fresh()->name);
        $this->assertTrue(Hash::check('clave-personal', $user->fresh()->password));
    }
}
